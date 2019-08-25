import TfLBusRepository

struct DisplayModel {
    let busStopCode: String
    let busStopName: String
    let line: String
    let arrivals: String
}

protocol ViewModel {
    func getDisplayModel(
        start: @escaping () -> Void,
        completion: @escaping (DisplayModel) -> Void
    )
}

protocol DisplayModelBuilder {
    func displayModelFrom(
        lineId: String,
        resultBusStop: Result<BusStop, TfLWrapperError>?,
        resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?
    ) -> DisplayModel
}

protocol ArrivalsTextFormatter {
    func arrivalsText(from arrivalsInSeconds: [Int]) -> String
}
