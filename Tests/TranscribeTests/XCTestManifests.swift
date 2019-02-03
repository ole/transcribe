import XCTest

extension AmazonRawTranscriptTests {
    static let __allTests = [
        ("test_parseAmazonTranscribeJSONFile", test_parseAmazonTranscribeJSONFile),
    ]
}

extension AmazonTranscriptTests {
    static let __allTests = [
        ("test_makeTranscriptFromTranscriptFile", test_makeTranscriptFromTranscriptFile),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AmazonRawTranscriptTests.__allTests),
        testCase(AmazonTranscriptTests.__allTests),
    ]
}
#endif
