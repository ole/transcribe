import XCTest
import Transcribe

final class AmazonTranscriptTests: XCTestCase {
    func test_makeTranscriptFromTranscriptFile() {
        let file = Bundle(for: type(of: self)).url(forResource: "amazon-transcribe-swift-community-podcast-0001", withExtension: "json")!
        do {
            let sut = try AmazonTranscribe.Transcript(transcriptFile: file)
            XCTAssertEqual(sut.segments.count, 324)
            XCTAssertEqual(sut.speakers.count, 4)
            let firstSegmentFragments = sut.segments[0].fragments
            let pronunciationFragments = firstSegmentFragments.filter { fragment in
                if case .pronunciation = fragment.kind { return true } else { return false }
            }
            let punctuationFragments = firstSegmentFragments.filter { fragment in
                if case .punctuation = fragment.kind { return true } else { return false }
            }
            XCTAssertEqual(firstSegmentFragments.count, 69)
            XCTAssertEqual(pronunciationFragments.count, 59)
            XCTAssertEqual(punctuationFragments.count, 10)
        } catch {
            XCTFail(String(reflecting: error))
        }
    }

    static var allTests = [
        ("test_makeTranscriptFromTranscriptFile", test_makeTranscriptFromTranscriptFile),
    ]
}
