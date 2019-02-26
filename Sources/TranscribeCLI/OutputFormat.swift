import Utility

enum OutputFormat: String, CaseIterable {
    case markdown
    case webvtt

    static let `default` = webvtt
}

extension OutputFormat: StringEnumArgument {
    static let completion: ShellCompletion = .values([
        (markdown.rawValue, "Markdown output format"),
        (webvtt.rawValue, "WebVTT output format")
    ])
}
