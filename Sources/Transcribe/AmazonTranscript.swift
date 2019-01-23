extension AmazonTranscribe {
    /// Model type for working with transcripts
    /// Use Transcript.init(transcriptFile:) to create this value from a TranscriptFile
    public struct Transcript {
        public var segments: [Segment]
        public var speakers: [Speaker]

        /// A list of consecutive fragments by the same speaker
        public struct Segment {
            public var time: Range<Timecode>
            public var speakerLabel: String
            public var fragments: [Fragment]
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
            /// The speaker label in the original `TranscriptFile`
            public var speakerLabel: String
            /// The speaker's name as it should appear in the formatted output.
            public var name: String
        }
    }
}

extension AmazonTranscribe.Transcript {
    public init(transcriptFile: AmazonTranscribe.TranscriptFile) throws {
        // Iterate over results.speaker_labels.segments
        let segments = try transcriptFile.results.speaker_labels.segments.map { rawSegment -> AmazonTranscribe.Transcript.Segment in
            let segmentTime = try Range(rawSegment)

            // Iterate over results.items and find all fragments that belong to this segment
            let rawSpeechFragments = try transcriptFile.results.items
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
    init(_ rawSegment: AmazonTranscribe.TranscriptFile.SpeakerSegment) throws {
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

    init(_ rawFragment: AmazonTranscribe.TranscriptFile.SpeakerSegment.Item) throws {
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

    init?(_ rawFragment: AmazonTranscribe.TranscriptFile.Item) throws {
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
