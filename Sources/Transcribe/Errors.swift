public enum ParseError: Error {
    case couldNotConvertStringToDouble(text: String, context: String)
    case startTimeMustBeSmallerThanEndTime(startTime: Timecode, endTime: Timecode, context: String)
}
