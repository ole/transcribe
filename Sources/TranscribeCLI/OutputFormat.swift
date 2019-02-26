import Utility

enum OutputFormat: String, CaseIterable {
    case markdown = "markdown"
    case webVTT = "webvtt"

    static let `default` = webVTT
}

extension OutputFormat: StringEnumArgument {
    static let completion: ShellCompletion = .values([
        (markdown.rawValue, "Markdown output format"),
        (webVTT.rawValue, "WebVTT output format")
    ])
}
