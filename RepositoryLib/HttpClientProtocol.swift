import Foundation

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
