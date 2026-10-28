import Foundation

/// Coordinates APNs registration requests. All methods run on the main thread.
final class APNsTokenTracker {
    enum Failure: LocalizedError, Equatable {
        case timedOut
        case emptyToken

        var errorDescription: String? {
            switch self {
            case .timedOut:
                return "APNs registration timed out. Check connectivity and push capabilities."
            case .emptyToken:
                return "APNs returned an empty device token."
            }
        }
    }

    typealias Completion = (Result<String, Error>) -> Void

    private let register: () -> Void
    private let timeout: TimeInterval
    private var completions: [Completion] = []
    private var timeoutWork: DispatchWorkItem?
    private var requestID: UUID?

    init(timeout: TimeInterval = 25, register: @escaping () -> Void) {
        self.timeout = timeout
        self.register = register
    }

    /// Requests a current token; concurrent callers share one registration.
    func getToken(completion: @escaping Completion) {
        dispatchPrecondition(condition: .onQueue(.main))
        completions.append(completion)
        guard requestID == nil else { return }

        let id = UUID()
        requestID = id
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.requestID == id else { return }
            self.finish(.failure(Failure.timedOut))
        }
        timeoutWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: work)
        register()
    }

    /// Uses hexadecimal bytes without assuming a fixed APNs token length.
    func didRegister(token: Data) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard !token.isEmpty else {
            finish(.failure(Failure.emptyToken))
            return
        }
        finish(.success(token.map { String(format: "%02x", $0) }.joined()))
    }

    func didFail(error: Error) {
        dispatchPrecondition(condition: .onQueue(.main))
        finish(.failure(error))
    }

    /// Drops pending requests when the Flutter engine detaches.
    func cancel() {
        dispatchPrecondition(condition: .onQueue(.main))
        timeoutWork?.cancel()
        timeoutWork = nil
        requestID = nil
        completions.removeAll()
    }

    private func finish(_ result: Result<String, Error>) {
        timeoutWork?.cancel()
        timeoutWork = nil
        requestID = nil
        let callbacks = completions
        completions.removeAll()
        callbacks.forEach { $0(result) }
    }
}
