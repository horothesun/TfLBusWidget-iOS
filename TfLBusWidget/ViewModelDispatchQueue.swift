import TfLBusRepository
import Dispatch

struct ViewModelDispatchQueue {

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let displayModelBuilder: DisplayModelBuilder
    private let processingQueue: DispatchQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        displayModelBuilder: DisplayModelBuilder,
        processingQueue: DispatchQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.displayModelBuilder = displayModelBuilder
        self.processingQueue = processingQueue
    }
}

extension ViewModelDispatchQueue: ViewModel {

    func getDisplayModel(
        start:  @escaping () -> Void,
        completion: @escaping (DisplayModel) -> Void
    ) {
        DispatchQueue.main.async(execute: start)

        processingQueue.async { [userConfiguration, tflWrapper, displayModelBuilder] in
            guard
                let stopId = userConfiguration.stopId,
                let lineId = userConfiguration.lineId
            else {
                let displayModel = DisplayModel.openAppDisplayModel
                DispatchQueue.main.async { completion(displayModel) }
                return
            }

            tflWrapper.busStop(stopId: stopId) { resultBusStop in
                tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId) { resultArrivals in
                    let displayModel = displayModelBuilder.displayModelFrom(
                        lineId: lineId,
                        resultBusStop: resultBusStop,
                        resultArrivalsInSeconds: resultArrivals
                    )
                    DispatchQueue.main.async { completion(displayModel) }
                }
            }
        }
    }
}
