import Foundation

public struct Timecode {
    /// Number of seconds since the start of the recording.
    public var seconds: TimeInterval

    public init(seconds: TimeInterval) {
        self.seconds = seconds
    }
    
    public init?(text: String) {
        guard let seconds = TimeInterval(text) else {
            return nil
        }
        self.seconds = seconds
    }
}

extension Timecode: Comparable {
    public static func <(lhs: Timecode, rhs: Timecode) -> Bool {
        return lhs.seconds < rhs.seconds
    }
}
