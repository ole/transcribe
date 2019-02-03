import var Darwin.stderr
import func Darwin.fputs

struct StandardError: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, Darwin.stderr)
    }
}

/// A TextOutputStream for stderr.
/// Use `print("...", to: stdError)` to print something to stderr.
var stdError = StandardError()
