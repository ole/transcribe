//
//  WebVTT.swift
//  Transcribe
//
//  Created by Julian Kahnert on 05.02.19.
//

import Foundation

public struct WebVTT {
    public var segments: [Segment]

    public struct Segment {
        public var time: Range<Timecode>
        public var speakerName: String
        public var sentence: String
    }
}

extension WebVTT {

    public static func aws2webvtt(_ awsTranscript: AmazonTranscribe.Transcript) -> WebVTT {

        // parsed segements will be saved here
        var segments = [Segment]()

        // prepare initial setup
        var speechBucket = ""
        var startTimecode: Timecode?
        var endTimecode: Timecode?

        for awsSegment in awsTranscript.segments {
            for awsFragment in awsSegment.fragments {
                switch awsFragment.kind {
                case .pronunciation(let pronunciation):

                    // add content to current bucket
                    speechBucket += pronunciation.content + " "

                    if startTimecode == nil {
                        // set first/start timecode of this segment
                        startTimecode = pronunciation.time.lowerBound
                    }

                    // increase the end timecode of this segment
                    endTimecode = pronunciation.time.upperBound

                case .punctuation(let punctuation):

                    // remove the last character, e.g. a space and add punctuation
                    speechBucket.removeLast()
                    speechBucket += punctuation

                    // save this segment
                    guard let start = startTimecode else { fatalError("No start timecode found!") }
                    guard let end = endTimecode else { fatalError("No end timecode found!") }
                    segments.append(Segment(time: start..<end,
                                            speakerName: awsSegment.speakerLabel,
                                            sentence: speechBucket))

                    // reset for the next (WebVTT) segment
                    startTimecode = nil
                    endTimecode = nil
                    speechBucket = ""
                }
            }
        }
        return WebVTT(segments: segments)
    }
}

extension WebVTT: CustomStringConvertible {
    public var description: String {

        var content = "WEBVTT\n\n"
        content += segments.map { $0.description }.joined()

        return content
    }
}

extension WebVTT.Segment: CustomStringConvertible {
    public var description: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        if let speechBegan = formatter.string(from: time.lowerBound.seconds),
            let speechEnded = formatter.string(from: time.upperBound.seconds) {
            return """
            \(speechBegan) --> \(speechEnded)
            <v \(self.speakerName)>\(sentence)
            \n
            """
        } else {
            // TODO: handle this case
            print("This should not happen!")
            return ""
        }
    }
}
