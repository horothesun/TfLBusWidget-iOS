import TfLBusRepository

struct ArrivalsTextFormatterDefault: ArrivalsTextFormatter {

    private typealias `Self` = ArrivalsTextFormatterDefault

    private static let noArrivalsAvailableText = "N/A"
    private static let dueText = "Due"
    private static let arrivalsSeparatorText = ", "

    func arrivalsText(from resultArrivals: Result<[Int], TfLWrapperError>, errorMessage: String) -> String {
        switch resultArrivals {
        case let .success(arrivals):
            return Self.arrivalsText(from: arrivals)
        case .failure:
            return errorMessage
        }
    }

    private static func arrivalsText(from arrivalsInSeconds: [Int]) -> String {
        return arrivalsInSeconds.isEmpty
            ? noArrivalsAvailableText
            : arrivalsInSeconds
                .lazy
                .map(minutes(from:))
                .map { minutes -> String in minutes == 0 ? dueText : minutesText(from: minutes) }
                .joined(separator: arrivalsSeparatorText)
    }

    private static func minutes(from seconds: Int) -> Int { return seconds / 60 }

    private static func minutesText(from minutes: Int) -> String { return "\(minutes)'" }
}
