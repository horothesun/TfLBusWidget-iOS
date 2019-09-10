import Foundation

public protocol StopAndLineIdsUseCase {
    func stopAndLineIds() -> (String, String)?
}

public protocol BusStopUseCase {
    func busStop(
        stopId: String,
        completion: @escaping (Result<BusStop, Error>) -> Void
    )
}

public protocol ArrivalsInMinutesUseCase {
    func arrivalsInMinutes(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<[Int], Error>) -> Void
    )
}

public protocol BusStopAndArrivalsInMinutesUseCase {
    func busStopAndArrivalsInMinutes(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<(BusStop, [Int]), Error>) -> Void
    )
}
