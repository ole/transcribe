import XCTest

extension AmazonRawTranscriptTests {
    static let __allTests = [
        ("test_parseAmazonTranscribeJSONFile", test_parseAmazonTranscribeJSONFile)
    ]
}

extension AmazonTranscriptTests {
    static let __allTests = [
        ("test_makeTranscriptFromFile", test_makeTranscriptFromFile)
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AmazonRawTranscriptTests.__allTests),
        testCase(AmazonTranscriptTests.__allTests)
    ]
}
#endif
