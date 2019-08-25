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
            arrivalsTextFormatter: arrivalsTextFormatter
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
        arrivalsTextFormatter: ArrivalsTextFormatter
    ) -> MakeDisplayModelOperation {
        let makeDisplayModel = MakeDisplayModelOperation { completion in
            let displayModel = displayModelFrom(
                lineId: lineId,
                resultBusStop: getBusStop.output,
                resultArrivalsInSeconds: getArrivals.output,
                with: arrivalsTextFormatter
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

    private static func displayModelFrom(
        lineId: String,
        resultBusStop: ResultBusStop?,
        resultArrivalsInSeconds: ResultArrivals?,
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
