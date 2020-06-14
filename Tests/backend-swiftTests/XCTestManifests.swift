import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(backend_swiftTests.allTests),
    ]
}
#endif
