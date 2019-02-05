/// Command-line utility that takes an input file in the Amazon Transcribe API JSON format
/// and converts it to Markdown.
///
/// Usage:
///
///     TranscribeCLI FILE
///
///     FILE: The input file. Must be in Amazon Transcribe JSON format.
///
///     The resulting Markdown and WebVTT file is saved to the current directory with the
///     same basename as the input file.

import Foundation
import Transcribe

struct TranscribeCLIError: Error {
    var code: Int
    var message: String

    static let missingArgument = TranscribeCLIError(code: 1, message: "Usage: \(CommandLine.arguments[0]) FILE")
    static func argumentIsNotAFile(argument: String) -> TranscribeCLIError {
        return TranscribeCLIError(code: 2, message: "\(argument) must be a file")
    }
}

// MARK: - Main program

do {
    guard CommandLine.arguments.count == 2 else {
        throw TranscribeCLIError.missingArgument
    }

    let inputFilename = CommandLine.arguments[1]
    let inputFile = URL(fileURLWithPath: inputFilename).standardizedFileURL
    guard let isRegularFile = try inputFile.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile, isRegularFile == true else {
        throw TranscribeCLIError.argumentIsNotAFile(argument: inputFile.path)
    }

    let transcript = try AmazonTranscribe.Transcript(file: inputFile)
    let outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    // write markdown file
    let markdown = transcript.makeMarkdown()
    let markdownOutputFilename = inputFile.deletingPathExtension().appendingPathExtension("md").lastPathComponent
    let markdownOutputFile = outputDirectory.appendingPathComponent(markdownOutputFilename)
    try Data(markdown.utf8).write(to: markdownOutputFile)

    // write webvtt file
    let webvtt = transcript.makeWebVTT()
    let webvttOutputFilename = inputFile.deletingPathExtension().appendingPathExtension("vtt").lastPathComponent
    let webvttOutputFile = outputDirectory.appendingPathComponent(webvttOutputFilename)
    try Data(webvtt.utf8).write(to: webvttOutputFile)

} catch let error as TranscribeCLIError {
    print("Error: \(error.message) (\(error.code))", to: &stdError)
    exit(Int32(error.code))
} catch {
    print("Error: \(error)", to: &stdError)
    exit(-1)
}
