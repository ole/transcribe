import XCTest
@testable import Transcribe

final class AmazonRawTranscriptTests: XCTestCase {
    func test_parseAmazonTranscribeJSONFile() {
        let file = Bundle(for: type(of: self)).url(forResource: "amazon-transcribe-swift-community-podcast-0001", withExtension: "json")!
        do {
            let sut = try AmazonTranscribe.RawTranscript(file: file)
            XCTAssertEqual(sut.jobName, "swift-community-podcast-0001")
            XCTAssertEqual(sut.accountId, "***REMOVED***")
            XCTAssertEqual(sut.results.speaker_labels.segments.count, 324)
            XCTAssertEqual(sut.results.speaker_labels.speakers, 4)
            XCTAssertEqual(sut.results.items.count, 15204)
        } catch {
            XCTFail(String(reflecting: error))
        }
    }

    static var allTests = [
        ("test_parseAmazonTranscribeJSONFile", test_parseAmazonTranscribeJSONFile),
    ]
}
