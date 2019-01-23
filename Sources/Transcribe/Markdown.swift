extension AmazonTranscribe.Transcript {
    public func makeMarkdown() -> String {
        let paragraphs: [String] = segments.map { segment in
            var text = segment.fragments.first?.content ?? ""
            for fragment in segment.fragments.dropFirst() {
                switch fragment.kind {
                case .pronunciation(let p):
                    text.append(" ")
                    text.append(p.content)
                case .punctuation(let content):
                    text.append(content)
                }
            }
            var speakerName = self[speaker: segment.speakerLabel]?.name ?? segment.speakerLabel
            if speakerName.isEmpty {
                speakerName = "(Unknown)"
            }
            return """
            \(segment.time.lowerBound.seconds)–\(segment.time.upperBound.seconds)<br>
            **\(speakerName)** \(text)
            """
        }
        return paragraphs.joined(separator: "\n\n")
    }
}
