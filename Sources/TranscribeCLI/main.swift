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

do {
    let outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    guard CommandLine.arguments.count == 2 else {
        throw TranscribeCLIError.missingArgument
    }

    let inputFilename = CommandLine.arguments[1]
    let inputFile = URL(fileURLWithPath: inputFilename).standardizedFileURL
    guard let isRegularFile = try inputFile.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile, isRegularFile == true else {
        throw TranscribeCLIError.argumentIsNotAFile(argument: inputFile.path)
    }

    let rawTranscript = try AmazonTranscribe.TranscriptFile(file: inputFile)
    var transcript = try AmazonTranscribe.Transcript(transcriptFile: rawTranscript)
    transcript[speaker: "spk_0"]?.name = "John Sundell"
    transcript[speaker: "spk_1"]?.name = "Garric Nahapetian"
    transcript[speaker: "spk_2"]?.name = "Chris Lattner"
    let markdown = transcript.makeMarkdown()

    let outputFilename = inputFile.deletingPathExtension().appendingPathExtension("md").lastPathComponent
    let outputFile = outputDirectory.appendingPathComponent(outputFilename)
    try Data(markdown.utf8).write(to: outputFile)
} catch let error as TranscribeCLIError {
    print("Error: \(error.message) (\(error.code))", to: &stdError)
    exit(Int32(error.code))
} catch {
    print("Error: \(error)", to: &stdError)
    exit(-1)
}
