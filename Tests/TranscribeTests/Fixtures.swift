import Foundation

enum TranscribeTestsError: Error {
    case fixturesDirectoryNotFound(fromFilePath: String, result: String)
}

/// Returns the URL of the directory where test fixtures are stored (i.e. input files we use in
/// unit tests to test that files are parsed correctly). We need this because SwiftPM doesn't
/// support including resources in (test) targets as of Swift 5.0.
///
/// This function attempts to infer the location of the test fixtures directory from the path
/// of the .swift file that calls it. The function relies on a hardcoded directory structure of this
/// form:
///
///     Package root
///     ├── ...
///     ├── Tests
///     |   ├── LinuxMain.swift
///     |   └── TranscribeTests
///     |   |   └── YOUR .swift FILE HERE   <--
///     └── TestFixtures                    <-- Finds TestFixtures dir here
///
/// - Parameter sourceFilePath: Used to pass in the path of the .swift file that invokes the function via
///   the default value `#file`. Do not change the default value.
/// - Throws: Throws an error if the function can't find the directory. You should abort the test
///   if this happens.
func fixturesDirectory(donotuse sourceFilePath: String = #file) throws -> URL {
    let directory = URL(fileURLWithPath: #file) // <Package_Root>/Tests/TranscribeTests/xyz.swift
        .deletingLastPathComponent()            // <Package_Root>/Tests/TranscribeTests/
        .deletingLastPathComponent()            // <Package_Root>/Tests/
        .deletingLastPathComponent()            // <Package_Root>/Tests/
        .appendingPathComponent("TestFixtures") // <Package_Root>/Tests/TestFixtures
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory),
        isDirectory.boolValue
    else {
        throw TranscribeTestsError.fixturesDirectoryNotFound(fromFilePath: sourceFilePath, result: directory.path)
    }
    return directory
}
