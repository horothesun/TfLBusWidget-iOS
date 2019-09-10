public final class BusStopAndArrivalsInMinutesUseCaseSequential {

    private let busStopUseCase: BusStopUseCase
    private let arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase

    public init(
        busStopUseCase: BusStopUseCase,
        arrivalsInMinutesUseCase: ArrivalsInMinutesUseCase
    ) {
        self.busStopUseCase = busStopUseCase
        self.arrivalsInMinutesUseCase = arrivalsInMinutesUseCase
    }
}

extension BusStopAndArrivalsInMinutesUseCaseSequential: BusStopAndArrivalsInMinutesUseCase {

    struct UseCaseError: Error { }

    public func busStopAndArrivalsInMinutes(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<(BusStop, [Int]), Error>) -> Void
    ) {
        // sequential calls ☹️
        busStopUseCase.busStop(stopId: stopId) { [arrivalsInMinutesUseCase] resultBusStop in
            arrivalsInMinutesUseCase
                .arrivalsInMinutes(stopId: stopId, lineId: lineId) { resultArrivalsInMinutes in
                    let result: Result<(BusStop, [Int]), Error>
                    switch (resultBusStop, resultArrivalsInMinutes) {
                    case let (.success(busStop), .success(arrivalsInMinutes)):
                        result = .success((busStop, arrivalsInMinutes))
                    default:
                        result = .failure(UseCaseError())
                    }
                    completion(result)
                }
        }
    }
}
