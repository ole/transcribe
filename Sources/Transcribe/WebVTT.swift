import Foundation

extension AmazonTranscribe.Transcript {
    /// Formats a Transcript data structure as a WebVTT string.
    public func makeWebVTT() -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let paragraphs: [String] = segments.map { segment in

            // get speaker name
            var speakerName = self[speaker: segment.speakerLabel]?.name ?? segment.speakerLabel
            if speakerName.isEmpty {
                speakerName = "(Unknown)"
            }

            // create timestamps
            let speechBegan = formatter.string(from: Date(timeIntervalSince1970: segment.time.lowerBound.seconds))
            let speechEnded = formatter.string(from: Date(timeIntervalSince1970: segment.time.upperBound.seconds))

            return """
            \(speechBegan) --> \(speechEnded)
            <v \(speakerName)>\(segment.text)
            """
        }

        return "WEBVTT\n\n" + paragraphs.joined(separator: "\n\n")
    }
}
