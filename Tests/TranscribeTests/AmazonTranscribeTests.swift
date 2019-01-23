import XCTest
import Transcribe

final class AmazonTranscribeTests: XCTestCase {
    func test_parseAmazonTranscribeJSONFile() {
        let file = Bundle(for: AmazonTranscribeTests.self).url(forResource: "amazon-transcribe-swift-community-podcast-0001", withExtension: "json")!
        do {
            _ = try AmazonTranscribe.TranscriptFile(file: file)
        } catch {
            XCTFail(String(reflecting: error))
        }
    }

    static var allTests = [
        ("test_parseAmazonTranscribeJSONFile", test_parseAmazonTranscribeJSONFile),
    ]
}
