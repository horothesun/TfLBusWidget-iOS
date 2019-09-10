import Foundation
import WidgetUseCases

final class ViewModelDispatchQueue {

    private typealias `Self` = ViewModelDispatchQueue

    private let stopAndLineIdsUseCase: StopAndLineIdsUseCase
    private let busStopUseCase: BusStopUseCase
    private let arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase
    private let arrivalsFormatter: ArrivalsFormatter
    private let processingQueue: DispatchQueue

    init(
        stopAndLineIdsUseCase: StopAndLineIdsUseCase,
        busStopUseCase: BusStopUseCase,
        arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase,
        arrivalsFormatter: ArrivalsFormatter,
        processingQueue: DispatchQueue
    ) {
        self.stopAndLineIdsUseCase = stopAndLineIdsUseCase
        self.busStopUseCase = busStopUseCase
        self.arrivalsInMinutesUseCase = arrivalsInMinutesUseCase
        self.arrivalsFormatter = arrivalsFormatter
        self.processingQueue = processingQueue
    }
}

extension ViewModelDispatchQueue: ViewModel {

    private static var openAppMessage: String { return "Launch the 'TfL Bus' app 👍" }
    private static var errorMessage: String { return "Oops, an error occurred 🙏" }

    func getDisplayModel(
        start:  @escaping () -> Void,
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void
    ) {
        DispatchQueue.main.async(execute: start)

        processingQueue.async { [stopAndLineIdsUseCase, busStopUseCase, arrivalsInMinutesUseCase, arrivalsFormatter] in
            guard let (stopId, lineId) = stopAndLineIdsUseCase.stopAndLineIds() else {
                DispatchQueue.main.async { failure(.init(message: Self.openAppMessage)) }
                return
            }

            // sequential calls ☹️
            busStopUseCase.busStop(stopId: stopId) { resultBusStop in
                arrivalsInMinutesUseCase.arrivalsInMinutes(stopId: stopId, lineId: lineId) { resultArrivals in
                    let resultDisplayModel = Self.displayModelFrom(
                        lineId: lineId,
                        resultBusStop: resultBusStop,
                        resultArrivalsInMinutes: resultArrivals,
                        arrivalsFormatter: arrivalsFormatter
                    )
                    DispatchQueue.main.async { resultDisplayModel.fold(success: success, failure: failure) }
                }
            }
        }
    }

    private static func displayModelFrom(
        lineId: String,
        resultBusStop: Result<BusStop, Error>,
        resultArrivalsInMinutes: Result<[Int], Error>,
        arrivalsFormatter: ArrivalsFormatter
    ) -> Result<SuccessDisplayModel, FailureDisplayModel> {
        guard
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
