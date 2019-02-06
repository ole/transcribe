import Foundation

extension AmazonTranscribe {
    /// Model type for working with transcripts
    /// Use `init(file:)` to create this value from a file or `init(rawTranscript:)`
    /// if you already have a `RawTranscript`.
    public struct Transcript {
        public var segments: [Segment]
        public var speakers: [Speaker]

        public subscript(speaker speakerLabel: String) -> Speaker? {
            get {
                return speakers.first(where: { $0.speakerLabel == speakerLabel })
            }
            set {
                guard let index = speakers.firstIndex(where: { $0.speakerLabel == speakerLabel }),
                    let newValue = newValue
                    else { return }
                speakers[index] = newValue
            }
        }

        /// A list of consecutive fragments by the same speaker
        public struct Segment {
            public let time: Range<Timecode>
            public let speakerLabel: String
            public let fragments: [Fragment]
            public var content: String {
                // TODO: this might be cached
                var text = fragments.first?.content ?? ""
                for fragment in fragments.dropFirst() {
                    switch fragment.kind {
                    case .pronunciation(let p):
                        text.append(" ")
                        text.append(p.content)
                    case .punctuation(let content):
                        text.append(content)
                    }
                }
                return text
            }
        }

        /// A fragment of transcribed speech. Could be a word or punctuation.
        public struct Fragment {
            public var kind: Kind
            public var speakerLabel: String

            public enum Kind {
                case pronunciation(Pronunciation)
                case punctuation(String)
            }

            public struct Pronunciation {
                var time: Range<Timecode>
                var content: String
            }
        }

        public struct Speaker {
            /// The speaker label in the original `RawTranscript`
            public var speakerLabel: String
            /// The speaker's name as it should appear in the formatted output.
            public var name: String
        }
    }
}

extension AmazonTranscribe.Transcript.Fragment {
    public var content: String {
        switch kind {
        case .pronunciation(let p):
            return p.content
        case .punctuation(let content):
            return content
        }
    }
}

extension AmazonTranscribe.Transcript {
    public init() {
        self.segments = []
        self.speakers = []
    }

    public init(file: URL) throws {
        let rawTranscript = try AmazonTranscribe.RawTranscript(file: file)
        try self.init(rawTranscript: rawTranscript)
    }

    public init(rawTranscript: AmazonTranscribe.RawTranscript) throws {
        // Iterate over results.speaker_labels.segments
        let segments = try rawTranscript.results.speaker_labels.segments.map { rawSegment -> AmazonTranscribe.Transcript.Segment in
            let segmentTime = try Range(rawSegment)

            // Iterate over results.items and find all fragments that belong to this segment
            let rawSpeechFragments = try rawTranscript.results.items
                .drop(while: { rawSpeechFragment in
                    guard let fragmentTime = try Range(rawSpeechFragment) else {
                        // Drop any segment without a timecode (e.g. punctuation)
                        return true
                    }
                    return fragmentTime.lowerBound < segmentTime.lowerBound
                })
                .prefix(while: { rawSpeechFragment in
                    guard let fragmentTime = try Range(rawSpeechFragment) else {
                        // Keep any segment without a timecode (e.g. punctuation)
                        return true
                    }
                    return fragmentTime.upperBound <= segmentTime.upperBound
                })

            // Construct Fragment values
            let fragments = try rawSpeechFragments.map { rawSpeechFragment -> Fragment in
                let kind: Fragment.Kind
                switch rawSpeechFragment.type {
                case .pronunciation:
                    guard let fragmentTime = try Range(rawSpeechFragment) else {
                        fatalError("Pronunciation fragment has no timecode: \(rawSpeechFragment)")
                    }
                    kind = .pronunciation(Fragment.Pronunciation(time: fragmentTime, content: rawSpeechFragment.alternatives[0].content))
                case .punctuation:
                    kind = .punctuation(rawSpeechFragment.alternatives[0].content)
                }
                return Fragment(kind: kind, speakerLabel: rawSegment.speaker_label)
            }
            return Segment(time: segmentTime, speakerLabel: rawSegment.speaker_label, fragments: fragments)
        }

        self.segments = segments
        let speakerLabels = Set(segments.map { $0.speakerLabel })
        self.speakers = speakerLabels.sorted().map { label in
            AmazonTranscribe.Transcript.Speaker(speakerLabel: label, name: label)
        }
    }
}

extension Range where Bound == Timecode {
    init(_ rawSegment: AmazonTranscribe.RawTranscript.SpeakerSegment) throws {
        guard let startTime = Timecode(text: rawSegment.start_time) else {
            throw ParseError.couldNotConvertStringToDouble(text: rawSegment.start_time, context: "results.speaker_labels.segments.start_time")
        }
        guard let endTime = Timecode(text: rawSegment.end_time) else {
            throw ParseError.couldNotConvertStringToDouble(text: rawSegment.end_time, context: "results.speaker_labels.segments.end_time")
        }
        guard startTime < endTime else {
            throw ParseError.startTimeMustBeSmallerThanEndTime(startTime: startTime, endTime: endTime, context: "results.speaker_labels.segments")
        }
        self = startTime..<endTime
    }

    init(_ rawFragment: AmazonTranscribe.RawTranscript.SpeakerSegment.Item) throws {
        guard let startTime = Timecode(text: rawFragment.start_time) else {
            throw ParseError.couldNotConvertStringToDouble(text: rawFragment.start_time, context: "results.speaker_labels.segments.items.start_time")
        }
        guard let endTime = Timecode(text: rawFragment.end_time) else {
            throw ParseError.couldNotConvertStringToDouble(text: rawFragment.end_time, context: "results.speaker_labels.segments.items.end_time")
        }
        guard startTime < endTime else {
            throw ParseError.startTimeMustBeSmallerThanEndTime(startTime: startTime, endTime: endTime, context: "results.speaker_labels.segments.items")
        }
        self = startTime..<endTime
    }

    init?(_ rawFragment: AmazonTranscribe.RawTranscript.Item) throws {
        guard let startTimeText = rawFragment.start_time, let endTimeText = rawFragment.end_time else {
            return nil
        }
        guard let startTime = Timecode(text: startTimeText) else {
            throw ParseError.couldNotConvertStringToDouble(text: startTimeText, context: "results.items.start_time")
        }
        guard let endTime = Timecode(text: endTimeText) else {
            throw ParseError.couldNotConvertStringToDouble(text: endTimeText, context: "results.items.end_time")
        }
        guard startTime < endTime else {
            throw ParseError.startTimeMustBeSmallerThanEndTime(startTime: startTime, endTime: endTime, context: "results.items")
        }
        self = startTime..<endTime
    }

}
