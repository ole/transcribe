import var Darwin.stderr
import func Darwin.fputs

struct StandardError: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, Darwin.stderr)
    }
}

var stdError = StandardError()
