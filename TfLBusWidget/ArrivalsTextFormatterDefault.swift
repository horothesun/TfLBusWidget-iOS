import TfLBusRepository

struct ArrivalsTextFormatterDefault: ArrivalsTextFormatter {

    private typealias `Self` = ArrivalsTextFormatterDefault

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
            ? "N/A"
            : arrivalsInSeconds
                .lazy
                .map(minutes(from:))
                .map { minutes -> String in minutes == 0 ? "Due" : "\(minutes)'" }
                .joined(separator: ", ")
    }

    private static func minutes(from seconds: Int) -> Int { return seconds / 60 }
}
