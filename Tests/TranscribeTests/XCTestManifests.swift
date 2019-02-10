import XCTest

extension AmazonRawTranscriptTests {
    static let __allTests = [
        ("test_parseAmazonTranscribeJSONFile", test_parseAmazonTranscribeJSONFile),
    ]
}

extension AmazonTranscriptTests {
    static let __allTests = [
        ("test_fragmentText_pronunciation", test_fragmentText_pronunciation),
        ("test_fragmentText_punctuation", test_fragmentText_punctuation),
        ("test_makeTranscriptFromFile", test_makeTranscriptFromFile),
        ("test_makeTranscriptFromFileShort", test_makeTranscriptFromFileShort),
        ("test_segmentText", test_segmentText),
        ("test_segmentText_trailingPronunciationShouldNotHaveTrailingSpace", test_segmentText_trailingPronunciationShouldNotHaveTrailingSpace),
    ]
}

extension WebVTTParserTest {
    static let __allTests = [
        ("test_parseAWSTranscript", test_parseAWSTranscript),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AmazonRawTranscriptTests.__allTests),
        testCase(AmazonTranscriptTests.__allTests),
        testCase(WebVTTParserTest.__allTests),
    ]
}
#endif
