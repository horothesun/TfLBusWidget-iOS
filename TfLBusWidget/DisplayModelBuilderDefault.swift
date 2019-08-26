import Foundation
import TfLBusRepository

struct DisplayModelBuilderDefault: DisplayModelBuilder {

    private typealias `Self` = DisplayModelBuilderDefault

    private static let errorMessage = "Oops, an error occurred 🙏"
    private static let noArrivalsAvailableText = "NA"
    private static let dueText = "Due"
    private static let arrivalsSeparatorText = ", "

    func displayModelFrom(
        lineId: String,
        resultBusStop: Result<BusStop, TfLWrapperError>?,
        resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?
    ) -> Result<DisplayModel, WidgetError> {
        guard
            let resultBusStop = resultBusStop,
            let resultArrivalsInSeconds = resultArrivalsInSeconds,
            case let .success(busStop) = resultBusStop,
            case let .success(arrivalsInSeconds) = resultArrivalsInSeconds
        else {
            return .failure(.error(message: Self.errorMessage))
        }

        return .success(
            .init(
                busStopCode: busStop.streetCode,
                busStopName: busStop.stopName,
                line: lineId.uppercased(),
                arrivals: Self.arrivalsText(from: arrivalsInSeconds)
            )
        )
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
