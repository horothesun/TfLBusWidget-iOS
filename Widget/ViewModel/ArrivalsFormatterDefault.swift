import Foundation

public final class ArrivalsFormatterDefault: ArrivalsFormatter {

    private typealias `Self` = ArrivalsFormatterDefault

    private static let noArrivalsAvailableText = "NA"
    private static let dueText = "Due"
    private static let arrivalsSeparatorText = ", "

    public init() { }

    public func arrivalsText(from arrivalsInMinutes: [Int]) -> String {
        return arrivalsInMinutes.isEmpty
            ? Self.noArrivalsAvailableText
            : arrivalsInMinutes
                .map { minutes -> String in minutes == 0 ? Self.dueText : "\(minutes)'" }
                .joined(separator: Self.arrivalsSeparatorText)
    }
}
