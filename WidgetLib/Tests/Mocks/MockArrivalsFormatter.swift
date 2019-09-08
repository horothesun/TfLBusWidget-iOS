import RepositoryLib
@testable import WidgetLib

final class MockArrivalsFormatter: ArrivalsFormatter {

    var arrivalsResult: String?

    func arrivalsText(from arrivalsInSeconds: [Int]) -> String {
        guard let arrivalsResult = arrivalsResult else {
            fatalError("\(#function): stub not defined")
        }

        return arrivalsResult
    }
}
