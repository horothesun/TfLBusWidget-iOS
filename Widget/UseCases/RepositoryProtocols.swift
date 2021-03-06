import Foundation

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
