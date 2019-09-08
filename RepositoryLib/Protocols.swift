import Foundation

struct ArrivalsResponse: Codable {
    let stopId: String
    let lineId: String
    let arrivalsInSeconds: [Int]
}

public enum HttpClientError: Error {
    case unknown(Error)
    case invalidPath
    case httpStatus(Int)
}

public protocol HttpClient {
    func fetch(
        path: String,
        completion: @escaping (Result<Data, HttpClientError>) -> Void
    )
}
