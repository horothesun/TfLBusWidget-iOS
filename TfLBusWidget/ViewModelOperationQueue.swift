import Foundation
import TfLBusOperations
import TfLBusRepository

final class ViewModelOperationQueue {

    private typealias `Self` = ViewModelOperationQueue
    private typealias ResultBusStop = Result<BusStop, TfLWrapperError>
    private typealias ResultArrivals = Result<[Int], TfLWrapperError>
    private typealias MakeDisplayModelOperation = Input2OutputOperation<ResultBusStop, ResultArrivals, DisplayModel>

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let displayModelBuilder: DisplayModelBuilder
    private let processingQueue: OperationQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        displayModelBuilder: DisplayModelBuilder,
        processingQueue: OperationQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.displayModelBuilder = displayModelBuilder
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

        let getBusStop = OutputOperation<ResultBusStop> { [tflWrapper] completion in
            tflWrapper.busStop(stopId: stopId, completion: completion)
        }
        let getArrivals = OutputOperation<ResultArrivals> { [tflWrapper] completion in
            tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId, completion: completion)
        }
        let makeDisplayModel = Self.makeDisplayModelOperation(
            lineId: lineId,
            getBusStop: getBusStop,
            getArrivals: getArrivals,
            completion: completion,
            displayModelBuilder: displayModelBuilder
        )
        let adapter = BlockOperation { [weak getBusStop, weak getArrivals, weak makeDisplayModel] in
            makeDisplayModel?.input1 = getBusStop?.output
            makeDisplayModel?.input2 = getArrivals?.output
        }

        adapter.addDependencies(getBusStop, getArrivals)
        makeDisplayModel.addDependency(adapter)

        processingQueue.addOperations(
            [getBusStop, getArrivals, adapter, makeDisplayModel],
            waitUntilFinished: false
        )
    }

    private static func makeDisplayModelOperation(
        lineId: String,
        getBusStop: OutputOperation<ResultBusStop>,
        getArrivals: OutputOperation<ResultArrivals>,
        completion: @escaping (DisplayModel) -> Void,
        displayModelBuilder: DisplayModelBuilder
    ) -> MakeDisplayModelOperation {
        let makeDisplayModel = MakeDisplayModelOperation { completion in
            let displayModel = displayModelBuilder.displayModelFrom(
                lineId: lineId,
                resultBusStop: getBusStop.output,
                resultArrivalsInSeconds: getArrivals.output
            )
            completion(displayModel)
        }
        makeDisplayModel.completionBlock = { [weak makeDisplayModel] in
            guard let displayModel = makeDisplayModel?.output else {
                OperationQueue.main.addOperation { completion(.errorDisplayModel) }
                return
            }

            OperationQueue.main.addOperation { completion(displayModel) }
        }
        return makeDisplayModel
    }
}
