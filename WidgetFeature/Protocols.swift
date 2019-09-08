import Foundation

public struct SuccessDisplayModel {
    public let busStopCode: String
    public let busStopName: String
    public let line: String
    public let arrivals: String
}

public struct FailureDisplayModel: Error {
    public let message: String
}

public protocol ViewModel {
    func getDisplayModel(
        start: @escaping () -> Void,
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void
    )
}

public enum TfLWrapperError: Error { case generic(Error) }

public struct BusStop: Codable {
    let id: String
    public let streetCode: String
    public let stopName: String

    public init(id: String, streetCode: String, stopName: String) {
        self.id = id
        self.streetCode = streetCode
        self.stopName = stopName
    }
}

public protocol TfLWrapper {
    func busStop(
        stopId: String,
        completion: @escaping (Result<BusStop, TfLWrapperError>) -> Void
    )
    func arrivalsInSeconds(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<[Int], TfLWrapperError>) -> Void
    )
}

public protocol UserConfiguration {
    var stopId: String? { get set }
    var lineId: String? { get set }
}

public protocol ArrivalsFormatter {
    func arrivalsText(from arrivalsInSeconds: [Int]) -> String
}
