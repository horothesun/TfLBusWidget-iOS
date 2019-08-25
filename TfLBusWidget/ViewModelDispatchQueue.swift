import TfLBusRepository
import Dispatch

struct ViewModelDispatchQueue {

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let arrivalsTextFormatter: ArrivalsTextFormatter
    private let processingQueue: DispatchQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        arrivalsTextFormatter: ArrivalsTextFormatter,
        processingQueue: DispatchQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.arrivalsTextFormatter = arrivalsTextFormatter
        self.processingQueue = processingQueue
    }
}

extension ViewModelDispatchQueue: ViewModel {

    func getDisplayModel(
        start:  @escaping () -> Void,
        completion: @escaping (DisplayModel) -> Void
    ) {
        DispatchQueue.main.async(execute: start)

        processingQueue.async { [userConfiguration, tflWrapper, arrivalsTextFormatter] in
            guard
                let stopId = userConfiguration.stopId,
                let lineId = userConfiguration.lineId
            else {
                let displayModel = DisplayModel.openAppDisplayModel
                DispatchQueue.main.async { completion(displayModel) }
                return
            }

            tflWrapper.busStop(stopId: stopId) { resultBusStop in

                switch resultBusStop {

                case .failure:
                    let displayModel = DisplayModel.errorDisplayModel
                    DispatchQueue.main.async { completion(displayModel) }

                case let .success(busStop):
                    tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId) { resultArrivals in
                        let arrivalsText = arrivalsTextFormatter.arrivalsText(
                            from: resultArrivals,
                            errorMessage: DisplayModel.errorMessage
                        )
                        let displayModel = DisplayModel(
                            busStopCode: busStop.streetCode,
                            busStopName: busStop.stopName,
                            line: lineId.uppercased(),
                            arrivals: arrivalsText
                        )
                        DispatchQueue.main.async { completion(displayModel) }
                    }
                }
            }
        }
    }
}
