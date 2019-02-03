# Transcribe

A Swift parser for output files from automated transcription services.

Created by [Ole Begemann](https://oleb.net), January 2019.

## Status

Very unstable and incomplete. I wrote this as an experiment to transcribe [episode 1 of the Swift Community Podcast](https://github.com/SwiftCommunityPodcast/podcast/issues/15).

## Supported File Formats

The only supported input file format is the JSON produced by the [Amazon Transcribe API](https://aws.amazon.com/transcribe/). It should be possible to add support for other formats (such as [Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text/)) and come up with a universal data structure that understands multiple input formats.

## Requirements

Swift 4.2. I only tested on macOS 10.14, but it should also run on other platforms supported by Swift.

## Dependencies

None.

## Components

The package consists of two targets:

- `Transcribe`: the library that implements the parsing of transcription files and conversion to other formats.
- `TranscribeCLI`: a command line tool that exposes some of the `Transcribe` functionality on the command line.

## Usage

If you want to create a new transcription, you must first create and run a transcription job on [Amazon Transcribe API](https://aws.amazon.com/transcribe/). This step is not part of this tool. When the transcription job completes, Amazon Transcribe will provide you with a JSON file with the transcription results. This file can be used as the input for this tool.

### In Code

To use the library in a SwiftPM package, add this to your `Package.swift`:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/ole/transcribe", .branch("master")),
    ],
    targets: [
        .target(name: "YOUR_TARGET", dependencies: ["Transcribe"]),
    ]
)
```

Import the module with `import Transcribe`.

Sample code:

```swift
import Transcribe

let inputFile = URL(fileURLWithPath: "input.json") // Change path to your input file
var transcript = try AmazonTranscribe.Transcript(file: inputFile)

// Print some statistics
print("Number of speakers:", transcript.speakers.count)
print("Speaker labels:", transcript.speakers.map { $0.speakerLabel })
print("Number of segments:", transcript.segments.count)
if let speechBegan = transcript.segments.first?.time.lowerBound,
    let speechEnded = transcript.segments.last?.time.upperBound
{
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    print("Speaking began at:", formatter.string(from: speechBegan.seconds) ?? "(unable to format timecode)")
    print("Speaking ended at:", formatter.string(from: speechEnded.seconds) ?? "(unable to format timecode)")
}

// Set/change speaker names
transcript[speaker: "spk_0"]?.name = "Alice"
transcript[speaker: "spk_1"]?.name = "Bob"

// Save as Markdown
let markdown = transcript.makeMarkdown()
let outputFile = URL(fileURLWithPath: "output.md") // Change path to your output file
try Data(markdown.utf8).write(to: outputFile)
```

### On the Command Line

The command line tool takes an input file and converts it to Markdown.

Usage:

```sh
swift run -c release TranscribeCLI transcript.json
```

This will produce an `transcript.md` file in the current directory.

## Overview of the Main Data Structures

The base data structure for a transcript. It contains a list of _segments_ and a list of _speakers_:

```swift
struct AmazonTranscribe.Transcript {
    public var segments: [Segment]
    public var speakers: [Speaker]
}
```

A _speaker_ has a label (which identifies the speaker in the transcript) and a name (which can be used when formatting a transcript for output, e.g. to Markdown).

```swift
struct AmazonTranscribe.Speaker {
    /// The speaker label in the original `RawTranscript`
    public var speakerLabel: String
    /// The speaker's name as it should appear in the formatted output.
    public var name: String
}
```

A _segment_ is a segment of spoken text, e.g. a sentence or paragraph. A segment has a time range (when it was spoken), a speaker (who spoke), and a list of _fragments_:

```swift
/// A list of consecutive fragments by the same speaker
struct AmazonTranscribe.Segment {
    var time: Range<Timecode>
    var speakerLabel: String
    var fragments: [Fragment]
}
```

A _fragment_ is a single unit of speech, like a single word or a punctuation character. The Amazon Transcribe API collects timecodes on this granularity.

```swift
/// A fragment of transcribed speech. Could be a word or punctuation.
struct AmazonTranscribe.Fragment {
    var kind: Kind
    var speakerLabel: String

    enum Kind {
        case pronunciation(Pronunciation)
        case punctuation(String)
    }

    struct Pronunciation {
        var time: Range<Timecode>
        var content: String
    }
}
```

There is also a `struct AmazonTranscribe.RawTranscript` type, which is a 1-to-1 mapping between the Amazon Transcribe JSON format and Swift data types. When you call `AmazonTranscribe.Transcript.init(file:)`, we parse the JSON into a `RawTranscript` value and then transform that into the `Transcript` data structures, which are easier to work with. Users of the library shouldn't need to deal with `RawTranscript` directly.

## License

[MIT](LICENSE.txt).
