import Foundation
import RepositoryLib

final class ArrivalsFormatterDefault: ArrivalsFormatter {

    private typealias `Self` = ArrivalsFormatterDefault

    private static let noArrivalsAvailableText = "NA"
    private static let dueText = "Due"
    private static let arrivalsSeparatorText = ", "

    func arrivalsText(from arrivalsInSeconds: [Int]) -> String {
        return arrivalsInSeconds.isEmpty
            ? Self.noArrivalsAvailableText
            : arrivalsInSeconds
                .lazy
                .map(Self.minutes(from:))
                .map { minutes -> String in minutes == 0 ? Self.dueText : Self.minutesText(from: minutes) }
                .joined(separator: Self.arrivalsSeparatorText)
    }

    private static func minutes(from seconds: Int) -> Int { return seconds / 60 }

    private static func minutesText(from minutes: Int) -> String { return "\(minutes)'" }
}
