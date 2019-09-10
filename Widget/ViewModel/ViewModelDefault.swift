import Foundation
import WidgetUseCases

public final class ViewModelDefault {

    private typealias `Self` = ViewModelDefault

    private let stopAndLineIdsUseCase: StopAndLineIdsUseCase
    private let busStopAndArrivalsInMinutesUseCase: BusStopAndArrivalsInMinutesUseCase
    private let arrivalsFormatter: ArrivalsFormatter
    private let processingQueue: DispatchQueue

    public init(
        stopAndLineIdsUseCase: StopAndLineIdsUseCase,
        busStopAndArrivalsInMinutesUseCase: BusStopAndArrivalsInMinutesUseCase,
        arrivalsFormatter: ArrivalsFormatter,
        processingQueue: DispatchQueue
    ) {
        self.stopAndLineIdsUseCase = stopAndLineIdsUseCase
        self.busStopAndArrivalsInMinutesUseCase = busStopAndArrivalsInMinutesUseCase
        self.arrivalsFormatter = arrivalsFormatter
        self.processingQueue = processingQueue
    }
}

extension ViewModelDefault: ViewModel {

    private static var openAppMessage: String { return "Launch the 'TfL Bus' app 👍" }
    private static var errorMessage: String { return "Oops, an error occurred 🙏" }

    public func getDisplayModel(
        start: @escaping () -> Void,
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void
    ) {
        DispatchQueue.main.async(execute: start)

        guard let (stopId, lineId) = stopAndLineIdsUseCase.stopAndLineIds() else {
            DispatchQueue.main.async { failure(.init(message: Self.openAppMessage)) }
            return
        }

        processingQueue.async { [busStopAndArrivalsInMinutesUseCase, arrivalsFormatter] in
            busStopAndArrivalsInMinutesUseCase.busStopAndArrivalsInMinutes(
                stopId: stopId,
                lineId: lineId
            ) { resultBusStopAndArrivalsInMinutes in
                let resultDisplayModel = resultBusStopAndArrivalsInMinutes
                    .map(Self.makeSuccessDisplayModel(for: lineId, with: arrivalsFormatter))
                    .mapError { _ in FailureDisplayModel(message: Self.errorMessage) }
                DispatchQueue.main.async { resultDisplayModel.fold(success: success, failure: failure) }
            }
        }
    }

    private static func makeSuccessDisplayModel(
        for lineId: String,
        with arrivalsFormatter: ArrivalsFormatter
    ) -> (BusStop, [Int]) -> SuccessDisplayModel {
        return { (busStop, arrivalsInMinutes) in
            .init(
                busStopCode: busStop.streetCode,
                busStopName: busStop.stopName,
                line: lineId.uppercased(),
                arrivals: arrivalsFormatter.arrivalsText(from: arrivalsInMinutes)
            )
        }
    }
}
