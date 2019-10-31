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
import SPMUtility

// MARK: - Main program

do {
    // Set up the argument parser
    let parser = ArgumentParser(usage: "<options>",
                                overview: "A Swift parser for output files from automated transcription services.")
    let inputFileArgument = parser.add(option: "--json", shortName: "-j", kind: PathArgument.self, usage: "Amazon Transcribe JSON file, e.g. './TestFixtures/amazon-transcribe-swift-community-podcast-0001.json'")
    let speakerNamesArgument = parser.add(option: "--names", shortName: "-n", kind: [String].self, usage: "Array of speaker names, e.g. 'alice bob'")
    let supportedOutputFormats = OutputFormat.allCases.map({ $0.rawValue }).joined(separator: ", ")
    let outputFormatArgument = parser.add(option: "--format", shortName: "-f", kind: OutputFormat.self, usage: "Specify the output format. Supported formats: \(supportedOutputFormats). The default is \(OutputFormat.default).", completion: OutputFormat.completion)
    let outputFileArgument = parser.add(option: "--output", shortName: "-o", kind: PathArgument.self, usage: "Output file path. If omitted, output will be written to the standard output.")
    
    // The first argument is always the executable, drop it
    let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
    let parsedArguments = try parser.parse(arguments)
    guard let inputFilename = parsedArguments.get(inputFileArgument),
        inputFilename.path.pathString.lowercased().hasSuffix("json") else {
        throw ArgumentParserError.invalidValue(argument: "--json", error: ArgumentConversionError.custom("No json file specified"))
    }
   
    // Validate input file
    let inputFile = inputFilename.path.asURL.standardizedFileURL
    guard let isRegularFile = try? inputFile.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile, isRegularFile == true else {
        throw ArgumentParserError.invalidValue(argument: "--json", error: ArgumentConversionError.custom("File not found"))
    }

    // Parse input file
    var transcript = try AmazonTranscribe.Transcript(file: inputFile)

    // Set speaker names
    if let speakerNames = parsedArguments.get(speakerNamesArgument) {
        // Counts of names passed on CLI and speakers in Transcript do not match => print warning
        if speakerNames.count != transcript.speakers.count {
            print("Warning: Number of speaker names passed in (\(speakerNames.count)) does not match the number of speakers in the transcript (\(transcript.speakers.count) – \(transcript.speakers.map { $0.speakerLabel }))", to: &stdError)
        }
        for (speakerName, speakerIndex) in zip(speakerNames, transcript.speakers.indices) {
            transcript.speakers[speakerIndex].name = speakerName
        }
    }
    
    let outputFormat = parsedArguments.get(outputFormatArgument) ?? .default

    // Generate the output text
    let output: String
    switch outputFormat {
    case .markdown:
        output = transcript.makeMarkdown()
    case .webVTT:
        output = transcript.makeWebVTT()
    }

    // Print output or write to file
    if let outputPath = parsedArguments.get(outputFileArgument) {
        let url = outputPath.path.asURL.standardizedFileURL
        try Data(output.utf8).write(to: url)
    } else {
        print(output.utf8)
    }

} catch {
    print("Error: \(error)", to: &stdError)
    exit(1)
}
