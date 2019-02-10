import Foundation

extension AmazonTranscribe.Transcript {
    /// Formats a Transcript data structure as a WebVTT string.
    /// - Seealso: https://en.wikipedia.org/wiki/WebVTT
    /// - Seealso: https://www.w3.org/TR/webvtt1/
    public func makeWebVTT() -> String {
        // Using a DateFormatter for formatting Timecodes (which aren't bound to a calendar date)
        // is problematic, but it works for now. I'd love to use a DateComponentsFormatter, but it
        // doesn't support fractional seconds (as of macOS 10.14). The best alternative might be to
        // implement the Timecode -> String conversion by hand.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let paragraphs: [String] = segments.map { segment in
            // Get speaker name
            var speakerName = self[speaker: segment.speakerLabel]?.name ?? segment.speakerLabel
            if speakerName.isEmpty {
                speakerName = "(Unknown)"
            }

            // Create timestamps
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
