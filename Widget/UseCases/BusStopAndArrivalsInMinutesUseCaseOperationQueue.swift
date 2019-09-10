import Foundation
import OperationsLib

public final class BusStopAndArrivalsInMinutesUseCaseOperationQueue {

    private typealias `Self` = BusStopAndArrivalsInMinutesUseCaseOperationQueue
    private typealias ResultBusStop = Result<BusStop, Error>
    private typealias ResultArrivals = Result<[Int], Error>
    private typealias ResultComposed = Result<(BusStop, [Int]), Error>
    private typealias ComposeResultsOperation = Input2OutputOperation<ResultBusStop, ResultArrivals, ResultComposed>

    private let busStopUseCase: BusStopUseCase
    private let arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase
    private let processingQueue: OperationQueue

    public init(
        busStopUseCase: BusStopUseCase,
        arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase,
        processingQueue: OperationQueue
    ) {
        self.busStopUseCase = busStopUseCase
        self.arrivalsInMinutesUseCase = arrivalsInMinutesUseCase
        self.processingQueue = processingQueue
    }
}

extension BusStopAndArrivalsInMinutesUseCaseOperationQueue: BusStopAndArrivalsInMinutesUseCase {

    struct UseCaseError: Error { }

    public func busStopAndArrivalsInMinutes(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<(BusStop, [Int]), Error>) -> Void
    ) {
        let getBusStop = OutputOperation<ResultBusStop> { [busStopUseCase] recordOutput in
            busStopUseCase.busStop(stopId: stopId, completion: recordOutput)
        }
        let getArrivals = OutputOperation<ResultArrivals> { [arrivalsInMinutesUseCase] recordOutput in
            arrivalsInMinutesUseCase.arrivalsInMinutes(stopId: stopId, lineId: lineId, completion: recordOutput)
        }
        let composeResults = Self.composeResultsOperation(
            lineId: lineId,
            getBusStop: getBusStop,
            getArrivals: getArrivals,
            completion: completion
        )
        let adapter = BlockOperation { [weak getBusStop, weak getArrivals, weak composeResults] in
            composeResults?.input1 = getBusStop?.output
            composeResults?.input2 = getArrivals?.output
        }

        adapter.addDependencies(getBusStop, getArrivals)
        composeResults.addDependency(adapter)

        processingQueue.addOperations(
            [getBusStop, getArrivals, adapter, composeResults],
            waitUntilFinished: false
        )
    }

    private static func composeResultsOperation(
        lineId: String,
        getBusStop: OutputOperation<ResultBusStop>,
        getArrivals: OutputOperation<ResultArrivals>,
        completion: @escaping (ResultComposed) -> Void
    ) -> ComposeResultsOperation {
        let composeResults = ComposeResultsOperation { recordOutput in
            let resultComposed = resultComposedFrom(
                lineId: lineId,
                resultBusStop: getBusStop.output,
                resultArrivalsInMinutes: getArrivals.output
            )
            recordOutput(resultComposed)
        }
        composeResults.completionBlock = { [weak composeResults] in
            guard let resultComposed = composeResults?.output else {
                completion(.failure(UseCaseError()))
                return
            }

            completion(resultComposed)
        }
        return composeResults
    }

    private static func resultComposedFrom(
        lineId: String,
        resultBusStop: ResultBusStop?,
        resultArrivalsInMinutes: ResultArrivals?
    ) -> ResultComposed {
        guard
            let resultBusStop = resultBusStop,
            let resultArrivalsInMinutes = resultArrivalsInMinutes,
            case let .success(busStop) = resultBusStop,
            case let .success(arrivalsInMinutes) = resultArrivalsInMinutes
        else {
            return .failure(UseCaseError())
        }

        return .success((busStop, arrivalsInMinutes))
    }
}
