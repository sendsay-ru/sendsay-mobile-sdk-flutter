import Foundation
import XCTest

let suite = XCTestSuite(forTestCaseClass: APNsTokenTrackerTests.self)
suite.run()
guard suite.testCaseCount == 5, let run = suite.testRun else {
    fatalError("Expected five native APNs tests")
}
exit(run.hasSucceeded ? 0 : 1)
