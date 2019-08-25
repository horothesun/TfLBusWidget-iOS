import TfLBusRepository
import Foundation

final class ViewModelOperationQueue {

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let arrivalsTextFormatter: ArrivalsTextFormatter
    private let processingQueue: OperationQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        arrivalsTextFormatter: ArrivalsTextFormatter,
        processingQueue: OperationQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.arrivalsTextFormatter = arrivalsTextFormatter
        self.processingQueue = processingQueue
    }
}

extension ViewModelOperationQueue: ViewModel {

    func getDisplayModel(
        start: @escaping () -> Void,
        completion: @escaping (DisplayModel) -> Void
    ) {
        OperationQueue.main.addOperation(start)

        guard
            let stopId = userConfiguration.stopId,
            let lineId = userConfiguration.lineId
        else {
            OperationQueue.main.addOperation { completion(.openAppDisplayModel) }
            return
        }

        let getBusStop = GetBusStopOperation(stopId: stopId, tflWrapper: tflWrapper)
        let getArrivals = GetArrivalsOperation(stopId: stopId, lineId: lineId, tflWrapper: tflWrapper)
        let makeDisplayModel = MakeDisplayModelOperation(lineId: lineId, arrivalsTextFormatter: arrivalsTextFormatter)
        let adapter = BlockOperation { [weak getBusStop, weak getArrivals, weak makeDisplayModel] in
            makeDisplayModel?.resultBusStop = getBusStop?.resultBusStop
            makeDisplayModel?.resultArrivalsInSeconds = getArrivals?.resultArrivalsInSeconds
        }

        makeDisplayModel.completionBlock = { [weak makeDisplayModel] in
            guard let displayModel = makeDisplayModel?.displayModel else {
                OperationQueue.main.addOperation { completion(.errorDisplayModel) }
                return
            }

            OperationQueue.main.addOperation { completion(displayModel) }
        }

        adapter.addDependencies(getBusStop, getArrivals)
        makeDisplayModel.addDependency(adapter)

        processingQueue.addOperations(
            [getBusStop, getArrivals, adapter, makeDisplayModel],
            waitUntilFinished: false
        )
    }
}
