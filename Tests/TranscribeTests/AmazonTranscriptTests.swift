import XCTest
import Transcribe

final class AmazonTranscriptTests: XCTestCase {
    func test_makeTranscriptFromTranscriptFile() {
        let file = Bundle(for: type(of: self)).url(forResource: "amazon-transcribe-swift-community-podcast-0001", withExtension: "json")!
        do {
            let transcriptFile = try AmazonTranscribe.TranscriptFile(file: file)
            let sut = try AmazonTranscribe.Transcript(transcriptFile: transcriptFile)
            XCTAssertEqual(sut.segments.count, 324)
            XCTAssertEqual(sut.speakers.count, 4)
            XCTAssertEqual(sut.segments[0].fragments.count(where: { if case .pronunciation = $0.kind { return true } else { return false }}), 59)
        } catch {
            XCTFail(String(reflecting: error))
        }
    }

    static var allTests = [
        ("test_makeTranscriptFromTranscriptFile", test_makeTranscriptFromTranscriptFile),
    ]
}
