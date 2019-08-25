import Foundation

public enum TfLWrapperError: Error { case generic(Error) }

public struct BusStop: Decodable {
    let id: String
    public let streetCode: String
    public let stopName: String
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

enum HttpClientError: Error {
    case unknown(Error)
    case invalidPath
    case httpStatus(Int)
}

protocol HttpClient {
    func fetch(
        path: String,
        completion: @escaping (Result<Data, HttpClientError>) -> Void
    )
}
