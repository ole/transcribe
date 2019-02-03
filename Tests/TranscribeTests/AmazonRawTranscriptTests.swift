import XCTest
@testable import Transcribe

final class AmazonRawTranscriptTests: XCTestCase {
    func test_parseAmazonTranscribeJSONFile() {
        do {
            let inputFile = try fixturesDirectory().appendingPathComponent("amazon-transcribe-swift-community-podcast-0001.json")
            let sut = try AmazonTranscribe.RawTranscript(file: inputFile)
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
