import Foundation
import TfLBusRepository

struct DisplayModel {
    let busStopCode: String
    let busStopName: String
    let line: String
    let arrivals: String
}

enum WidgetError: Error { case error(message: String) }

protocol ViewModel {
    func getDisplayModel(
        start: @escaping () -> Void,
        success: @escaping (DisplayModel) -> Void,
        failure: @escaping (String) -> Void
    )
}

protocol DisplayModelBuilder {
    func displayModelFrom(
        lineId: String,
        resultBusStop: Result<BusStop, TfLWrapperError>?,
        resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?
    ) -> Result<DisplayModel, WidgetError>
}

protocol ArrivalsTextFormatter {
    func arrivalsText(from arrivalsInSeconds: [Int]) -> String
}
