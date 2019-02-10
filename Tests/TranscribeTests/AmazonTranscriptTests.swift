import Transcribe
import XCTest

final class AmazonTranscriptTests: XCTestCase {
    func test_makeTranscriptFromFile() {
        do {
            let inputFile = try fixturesDirectory().appendingPathComponent("amazon-transcribe-swift-community-podcast-0001.json")
            let sut = try AmazonTranscribe.Transcript(file: inputFile)
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

    func test_makeTranscriptFromFileShort() {
        do {
            let inputFile = try fixturesDirectory().appendingPathComponent("amazon-transcribe-swift-community-podcast-0001-formatted-short.json")
            let sut = try AmazonTranscribe.Transcript(file: inputFile)
            XCTAssertEqual(sut.segments.count, 2)
            XCTAssertEqual(sut.speakers.count, 2)
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

    func test_fragmentContent_pronunciation() {
        let sut = AmazonTranscribe.Transcript.Fragment(
            kind: .pronunciation(.init(
                time: Timecode(seconds: 0)..<Timecode(seconds: 1),
                content: "Hello")),
            speakerLabel: "Alice")
        XCTAssertEqual(sut.content, "Hello")
    }

    func test_fragmentContent_punctuation() {
        let sut = AmazonTranscribe.Transcript.Fragment(kind: .punctuation(","), speakerLabel: "Alice")
        XCTAssertEqual(sut.content, ",")
    }

    static var allTests = [
        ("test_makeTranscriptFromFile", test_makeTranscriptFromFile),
        ("test_makeTranscriptFromFileShort", test_makeTranscriptFromFileShort)
    ]
}
