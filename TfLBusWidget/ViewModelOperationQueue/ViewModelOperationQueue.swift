import TfLBusRepository
import Foundation

final class ViewModelOperationQueue {

    private typealias `Self` = ViewModelOperationQueue

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

        let getBusStop = OutputOperation<Result<BusStop, TfLWrapperError>> { [tflWrapper] completion in
            tflWrapper.busStop(stopId: stopId, completion: completion)
        }
        let getArrivals = OutputOperation<Result<[Int], TfLWrapperError>> { [tflWrapper] completion in
            tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId, completion: completion)
        }
        let makeDisplayModel = Self.makeDisplayModelOperation(
            lineId: lineId,
            getBusStop: getBusStop,
            getArrivals: getArrivals,
            arrivalsTextFormatter: arrivalsTextFormatter
        )
        makeDisplayModel.completionBlock = { [weak makeDisplayModel] in
            guard let displayModel = makeDisplayModel?.output else {
                OperationQueue.main.addOperation { completion(.errorDisplayModel) }
                return
            }

            OperationQueue.main.addOperation { completion(displayModel) }
        }
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
        getBusStop: OutputOperation<Result<BusStop, TfLWrapperError>>,
        getArrivals: OutputOperation<Result<[Int], TfLWrapperError>>,
        arrivalsTextFormatter: ArrivalsTextFormatter
    ) -> Input2OutputOperation<Result<BusStop, TfLWrapperError>, Result<[Int], TfLWrapperError>, DisplayModel> {
        return .init { completion in
            let displayModel = Self.displayModelFrom(
                lineId: lineId,
                resultBusStop: getBusStop.output,
                resultArrivalsInSeconds: getArrivals.output,
                with: arrivalsTextFormatter
            )
            completion(displayModel)
        }
    }

    private static func displayModelFrom(
        lineId: String,
        resultBusStop: Result<BusStop, TfLWrapperError>?,
        resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?,
        with arrivalsTextFormatter: ArrivalsTextFormatter
    ) -> DisplayModel {
        guard
            let resultBusStop = resultBusStop,
            let resultArrivalsInSeconds = resultArrivalsInSeconds,
            case let .success(busStop) = resultBusStop,
            case let .success(arrivalsInSeconds) = resultArrivalsInSeconds
        else {
            return .errorDisplayModel
        }

        let arrivalsText = arrivalsTextFormatter.arrivalsText(
            from: .success(arrivalsInSeconds),
            errorMessage: DisplayModel.errorMessage
        )
        return DisplayModel(
            busStopCode: busStop.streetCode,
            busStopName: busStop.stopName,
            line: lineId.uppercased(),
            arrivals: arrivalsText
        )
    }
}
