import TfLBusRepository

struct DisplayModel {
    let busStopCode: String
    let busStopName: String
    let line: String
    let arrivalsText: String
}

protocol ViewModel {
    func getDisplayModel(
        start: @escaping () -> Void,
        completion: @escaping (DisplayModel) -> Void
    )
}

protocol ArrivalsTextFormatter {
    func arrivalsText(
        from resultArrivals: Result<[Int], TfLWrapperError>,
        errorMessage: String
    ) -> String
}
