import TfLBusRepository

final class MakeDisplayModelOperation: AsyncOperation {

    // inputs
    var resultBusStop: Result<BusStop, TfLWrapperError>?
    var resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?

    // output
    var displayModel: DisplayModel?

    private let lineId: String
    private let arrivalsTextFormatter: ArrivalsTextFormatter

    init(
        lineId: String,
        arrivalsTextFormatter: ArrivalsTextFormatter
    ) {
        self.lineId = lineId
        self.arrivalsTextFormatter = arrivalsTextFormatter
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        executing(true)

        guard
            let resultBusStop = resultBusStop,
            let resultArrivalsInSeconds = resultArrivalsInSeconds
        else {
            terminateWith(displayModel: .errorDisplayModel)
            return
        }

        guard
            case let .success(busStop) = resultBusStop,
            case let .success(arrivalsInSeconds) = resultArrivalsInSeconds
        else {
            terminateWith(displayModel: .errorDisplayModel)
            return
        }

        let arrivalsText = arrivalsTextFormatter.arrivalsText(
            from: .success(arrivalsInSeconds),
            errorMessage: DisplayModel.errorMessage
        )
        terminateWith(displayModel:
            DisplayModel(
                busStopCode: busStop.streetCode,
                busStopName: busStop.stopName,
                line: lineId.uppercased(),
                arrivalsText: arrivalsText
            )
        )
    }

    private func terminateWith(displayModel: DisplayModel) {
        self.displayModel = displayModel
        executing(false)
        finish(true)
    }
}
