import Foundation
import OperationsLib
import WidgetUseCases

final class ViewModelOperationQueue {

    private typealias `Self` = ViewModelOperationQueue
    private typealias ResultBusStop = Result<BusStop, Error>
    private typealias ResultArrivals = Result<[Int], Error>
    private typealias ResultDisplayModel = Result<SuccessDisplayModel, FailureDisplayModel>
    private typealias MakeDisplayModelOperation = Input2OutputOperation<ResultBusStop, ResultArrivals, ResultDisplayModel>

    private let stopAndLineIdsUseCase: StopAndLineIdsUseCase
    private let busStopUseCase: BusStopUseCase
    private let arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase
    private let arrivalsFormatter: ArrivalsFormatter
    private let processingQueue: OperationQueue

    init(
        stopAndLineIdsUseCase: StopAndLineIdsUseCase,
        busStopUseCase: BusStopUseCase,
        arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase,
        arrivalsFormatter: ArrivalsFormatter,
        processingQueue: OperationQueue
    ) {
        self.stopAndLineIdsUseCase = stopAndLineIdsUseCase
        self.busStopUseCase = busStopUseCase
        self.arrivalsInMinutesUseCase = arrivalsInMinutesUseCase
        self.arrivalsFormatter = arrivalsFormatter
        self.processingQueue = processingQueue
    }
}

extension ViewModelOperationQueue: ViewModel {

    private static var openAppMessage: String { return "Launch the 'TfL Bus' app 👍" }
    private static var errorMessage: String { return "Oops, an error occurred 🙏" }

    func getDisplayModel(
        start: @escaping () -> Void,
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void
    ) {
        OperationQueue.main.addOperation(start)

        guard let (stopId, lineId) = stopAndLineIdsUseCase.stopAndLineIds() else {
            OperationQueue.main.addOperation { failure(.init(message: Self.openAppMessage)) }
            return
        }

        let getBusStop = OutputOperation<ResultBusStop> { [busStopUseCase] recordOutput in
            busStopUseCase.busStop(stopId: stopId, completion: recordOutput)
        }
        let getArrivals = OutputOperation<ResultArrivals> { [arrivalsInMinutesUseCase] recordOutput in
            arrivalsInMinutesUseCase.arrivalsInMinutes(stopId: stopId, lineId: lineId, completion: recordOutput)
        }
        let makeDisplayModel = Self.makeDisplayModelOperation(
            lineId: lineId,
            getBusStop: getBusStop,
            getArrivals: getArrivals,
            success: success,
            failure: failure,
            arrivalsFormatter: arrivalsFormatter
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
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void,
        arrivalsFormatter: ArrivalsFormatter
    ) -> MakeDisplayModelOperation {
        let makeDisplayModel = MakeDisplayModelOperation { recordOutput in
            let resultDisplayModel = displayModelFrom(
                lineId: lineId,
                resultBusStop: getBusStop.output,
                resultArrivalsInMinutes: getArrivals.output,
                arrivalsFormatter: arrivalsFormatter
            )
            recordOutput(resultDisplayModel)
        }
        makeDisplayModel.completionBlock = { [weak makeDisplayModel] in
            guard let resultDisplayModel = makeDisplayModel?.output else {
                OperationQueue.main.addOperation { failure(.init(message: errorMessage)) }
                return
            }

            OperationQueue.main.addOperation { resultDisplayModel.fold(success: success, failure: failure) }
        }
        return makeDisplayModel
    }

    private static func displayModelFrom(
        lineId: String,
        resultBusStop: ResultBusStop?,
        resultArrivalsInMinutes: ResultArrivals?,
        arrivalsFormatter: ArrivalsFormatter
    ) -> Result<SuccessDisplayModel, FailureDisplayModel> {
        guard
            let resultBusStop = resultBusStop,
            let resultArrivalsInMinutes = resultArrivalsInMinutes,
            case let .success(busStop) = resultBusStop,
            case let .success(arrivalsInMinutes) = resultArrivalsInMinutes
        else {
            return .failure(.init(message: Self.errorMessage))
        }

        return .success(
            .init(
                busStopCode: busStop.streetCode,
                busStopName: busStop.stopName,
                line: lineId.uppercased(),
                arrivals: arrivalsFormatter.arrivalsText(from: arrivalsInMinutes)
            )
        )
    }
}
