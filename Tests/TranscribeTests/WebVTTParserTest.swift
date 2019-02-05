//
//  WebVTTParserTest.swift
//  Transcribe
//
//  Created by Julian Kahnert on 05.02.19.
//

import Transcribe
import XCTest

final class WebVTTParserTest: XCTestCase {

    func test_parseAWSTranscript() {
        do {

            // prepare
            let inputFile = try fixturesDirectory().appendingPathComponent("amazon-transcribe-swift-community-podcast-0001-formatted-short.json")
            let sut = try AmazonTranscribe.Transcript(file: inputFile)
            XCTAssertEqual(sut.segments.count, 2)
            XCTAssertEqual(sut.speakers.count, 2)
            let referenceSegmentContent = """
            0:00:00 --> 0:00:05
            <v spk_0>Welcome to the very first episode of the Swift Community Podcast.
            \n
            """

            // calculate
            let webvtt = WebVTT.aws2webvtt(sut)

            // assert
            XCTAssertEqual(webvtt.segments.count, 13)
            XCTAssertEqual(webvtt.segments[0].description, referenceSegmentContent)

        } catch {
            XCTFail(String(reflecting: error))
        }
    }

    static var allTests = [
        ("test_parseAWSTranscript", test_parseAWSTranscript)
    ]
}
