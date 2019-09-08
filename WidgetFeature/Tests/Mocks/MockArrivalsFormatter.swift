import RepositoryLib
@testable import WidgetFeature

final class MockArrivalsFormatter: ArrivalsFormatter {

    var arrivalsResult: String?

    func arrivalsText(from arrivalsInSeconds: [Int]) -> String {
        guard let arrivalsResult = arrivalsResult else {
            fatalError("\(#function): stub not defined")
        }

        return arrivalsResult
    }
}
