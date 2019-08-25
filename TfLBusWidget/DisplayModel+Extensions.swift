extension DisplayModel {

    private static var undefinedText: String { return "-" }

    static var openAppMessage: String { return "Open the 'TfL Bus' app 👍" }
    static var errorMessage: String { return "Oops, an error occurred 🙏" }

    static var openAppDisplayModel: DisplayModel {
        return .init(
            busStopCode: undefinedText,
            busStopName: undefinedText,
            line: undefinedText,
            arrivals: openAppMessage
        )
    }

    static var errorDisplayModel: DisplayModel {
        return .init(
            busStopCode: undefinedText,
            busStopName: undefinedText,
            line: undefinedText,
            arrivals: errorMessage
        )
    }
}
