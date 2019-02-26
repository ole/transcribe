/// Command-line utility that takes an input file in the Amazon Transcribe API JSON format
/// and converts it to Markdown.
///
/// Usage:
///
///     TranscribeCLI --json FILE
///     TranscribeCLI --json FILE --names SPEAKER SPEAKER
///
///     FILE: The input file. Must be in Amazon Transcribe JSON format.
///     SPEAKER: Name of the speaker. Should be ordered by appearance.
///
///     The resulting Markdown or WebVTT output will be written into the standard output.

import Foundation
import Transcribe
import Utility

// MARK: - Main program

do {
    // setup the argument parser
    let parser = ArgumentParser(usage: "<options>",
                                overview: "A Swift parser for output files from automated transcription services.")
    let rawInputFilename = parser.add(option: "--json", shortName: "-j", kind: PathArgument.self, usage: "Amazon transcribe json file, e.g. './TestFixtures/amazon-transcribe-swift-community-podcast-0001-formatted-short.json'")
    let rawSpeakerNames = parser.add(option: "--names", shortName: "-n", kind: [String].self, usage: "Array of speaker names, e.g. 'alice bob'")
    let possibleOutputFormats = OutputFormat.allCases.map({ $0.rawValue }).joined(separator: ", ")
    let outputFormatArgument = parser.add(option: "--format", shortName: "-f", kind: OutputFormat.self, usage: "Specify the output format. Possible values are \(possibleOutputFormats). If omitted, \(OutputFormat.default) will be used.", completion: OutputFormat.completion)
    let outputArgument = parser.add(option: "--output", shortName: "-o", kind: PathArgument.self, usage: "Specify the output file path. If omitted, output will be written into the standard output.")
    
    // The first argument is always the executable, drop it
    let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
    let parsedArguments = try parser.parse(arguments)
    guard let inputFilename = parsedArguments.get(rawInputFilename),
        inputFilename.path.asString.lowercased().hasSuffix("json") else {
        throw ArgumentParserError.invalidValue(argument: "--json", error: ArgumentConversionError.custom("No json file specified"))
    }
   
    // validate json filename
    let inputFile = URL(fileURLWithPath: inputFilename.path.asString).standardizedFileURL
    guard let isRegularFile = try? inputFile.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile, isRegularFile == true else {
        throw ArgumentParserError.invalidValue(argument: "--json", error: ArgumentConversionError.custom("File not found"))
    }

    // parse the amazon transcription json file
    var transcript = try AmazonTranscribe.Transcript(file: inputFile)

    // Set speaker names
    if let speakerNames = parsedArguments.get(rawSpeakerNames) {
        // Counts of names passed on CLI and speakers in Transcript do not match => print warning
        if speakerNames.count != transcript.speakers.count {
            print("Warning: Number of speaker names passed in (\(speakerNames.count)) does not match the number of speakers in the transcript (\(transcript.speakers.count) – \(transcript.speakers.map { $0.speakerLabel }))", to: &stdError)
        }
        
        for (speakerName, speakerIndex) in zip(speakerNames, transcript.speakers.indices) {
            transcript.speakers[speakerIndex].name = speakerName
        }
    }
    
    let outputFormat = parsedArguments.get(outputFormatArgument) ?? .default

    let output: String
    switch outputFormat {
    case .markdown:
        output = transcript.makeMarkdown()
    case .webvtt:
        output = transcript.makeWebVTT()
    }

    if let outputPath = parsedArguments.get(outputArgument) {
        let url = URL(fileURLWithPath: outputPath.path.asString)
        try Data(output.utf8).write(to: url)
    } else {
        print(output.utf8)
    }

} catch {
    print("Error: \(error)", to: &stdError)
    exit(-1)
}
