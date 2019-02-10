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
            var sut = try AmazonTranscribe.Transcript(file: inputFile)
            XCTAssertEqual(sut.segments.count, 2)
            XCTAssertEqual(sut.speakers.count, 2)
            let referenceSegmentContent = """
            WEBVTT

            00:00:00.540 --> 00:00:21.250
            <v spk_0>Welcome to the very first episode of the Swift Community Podcast. A show for the Swift community by the Swift Community. I am one of your hosts, John Sindel. And with me, I have two wonderful co hosts, the first of which you might know as the host of the Swift coders podcast. Mr. Garric Nahapetian. How's going Garric?
            """

            // calculate
            sut.segments.removeLast(sut.segments.count - 1)
            let webvtt = sut.makeWebVTT()

            // assert
            XCTAssertEqual(sut.segments[0].text, "Welcome to the very first episode of the Swift Community Podcast. A show for the Swift community by the Swift Community. I am one of your hosts, John Sindel. And with me, I have two wonderful co hosts, the first of which you might know as the host of the Swift coders podcast. Mr. Garric Nahapetian. How's going Garric?")
            XCTAssertEqual(webvtt, referenceSegmentContent)

        } catch {
            XCTFail(String(reflecting: error))
        }
    }

    static var allTests = [
        ("test_parseAWSTranscript", test_parseAWSTranscript)
    ]
}
