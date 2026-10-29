import Foundation
import XCTest
@testable import APNsTracker

final class APNsTokenTrackerTests: XCTestCase {
    @objc func testConcurrentRequestsShareRegistrationAndUseHexToken() {
        var registrations = 0
        let tracker = APNsTokenTracker { registrations += 1 }
        var tokens: [String] = []
        tracker.getToken { tokens.append(try! $0.get()) }
        tracker.getToken { tokens.append(try! $0.get()) }
        XCTAssertEqual(registrations, 1)
        tracker.didRegister(token: Data([0, 171, 255]))
        XCTAssertEqual(tokens, ["00abff", "00abff"])
        tracker.getToken { _ in }
        XCTAssertEqual(registrations, 2)
        tracker.cancel()
    }

    @objc func testFailureReachesCallerAndAllowsRetry() {
        let tracker = APNsTokenTracker(register: {})
        let failure = NSError(domain: "APNs", code: 42)
        var receivedError: NSError?
        tracker.getToken {
            if case .failure(let error) = $0 { receivedError = error as NSError }
        }
        tracker.didFail(error: failure)
        XCTAssertEqual(receivedError, failure)
        var token: String?
        tracker.getToken { token = try? $0.get() }
        tracker.didRegister(token: Data([1]))
        XCTAssertEqual(token, "01")
    }

    @objc func testEmptyTokenFails() {
        let tracker = APNsTokenTracker(register: {})
        var failure: APNsTokenTracker.Failure?
        tracker.getToken {
            if case .failure(let error) = $0 {
                failure = error as? APNsTokenTracker.Failure
            }
        }
        tracker.didRegister(token: Data())
        XCTAssertEqual(failure, .emptyToken)
    }

    @objc func testTimeoutCompletesAndAllowsRetry() {
        let tracker = APNsTokenTracker(timeout: 0.01, register: {})
        let timedOut = expectation(description: "APNs timeout")
        tracker.getToken {
            if case .failure(let error) = $0 {
                XCTAssertEqual(error as? APNsTokenTracker.Failure, .timedOut)
                timedOut.fulfill()
            }
        }
        wait(for: [timedOut], timeout: 1)
        var token: String?
        tracker.getToken { token = try? $0.get() }
        tracker.didRegister(token: Data([2]))
        XCTAssertEqual(token, "02")
    }

    @objc func testCancelDropsPendingAndLateCallbacks() {
        let tracker = APNsTokenTracker(register: {})
        tracker.getToken { _ in XCTFail("Detached engine must not receive a result") }
        tracker.cancel()
        tracker.didRegister(token: Data([3]))
        tracker.didFail(error: NSError(domain: "APNs", code: 1))
    }
}
