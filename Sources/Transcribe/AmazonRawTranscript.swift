import Foundation

extension AmazonTranscribe {
    /// A 1-to-1 reproduction of the format of an Amazon Transcribe transcription result JSON file.
    /// The aim is to map the file format as-is, not to make it as Swift-friendly as possible.
    /// Field names and types follow the original JSON structure.
    public struct RawTranscript: Decodable {
        var jobName: String
        var accountId: String
        var results: Results

        struct Results: Decodable {
            var transcripts: [Transcript]
            var speaker_labels: SpeakerLabels
            var items: [Item]
        }

        struct Transcript: Decodable {
            var transcript: String
        }

        struct SpeakerLabels: Decodable {
            var speakers: Int
            var segments: [SpeakerSegment]
        }

        struct SpeakerSegment: Decodable {
            var speaker_label: String
            var start_time: String
            var end_time: String
            var items: [Item]

            struct Item: Decodable {
                var speaker_label: String
                var start_time: String
                var end_time: String
            }
        }

        struct Item: Decodable {
            var start_time: String?
            var end_time: String?
            var alternatives: [Alternative]
            var type: Kind

            struct Alternative: Decodable {
                var content: String
                var confidence: String?
            }

            enum Kind: String, Decodable {
                case pronunciation
                case punctuation
            }
        }
    }
}

extension AmazonTranscribe.RawTranscript {
    /// Loads and parses an Amazon Transcribe transcription result JSON file.
    public init(file: URL) throws {
        let jsonData = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        self = try decoder.decode(AmazonTranscribe.RawTranscript.self, from: jsonData)
    }
}
