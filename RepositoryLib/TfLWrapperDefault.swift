import Foundation
import WidgetUseCases

struct ArrivalsResponse: Codable {
    let stopId: String
    let lineId: String
    let arrivalsInSeconds: [Int]
}

public final class TfLWrapperDefault {

    private typealias `Self` = TfLWrapperDefault

    private let httpClient: HttpClient

    public init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
}

extension TfLWrapperDefault: WidgetUseCases.TfLWrapper {

    enum TfLWrapperDefaultError: Error { case jsonParsingError }

    private var baseURL: String { return "https://tfl-wrapper.herokuapp.com/" }

    public func busStop(
        stopId: String,
        completion: @escaping (Result<BusStop, TfLWrapperError>) -> Void
    ) {
//        Thread.sleep(forTimeInterval: 1)
//        completion(.success(BusStop(id: "490001302S", streetCode: "S", stopName: "UPPER HOLLOWAY STATION")))

//        completion(.failure(.generic(TfLWrapperDefaultError.jsonParsingError)))

        let path = "\(baseURL)v1/bus-stops/\(stopId)"
        httpClient.fetch(path: path) { resultData in
            let resultBusStop = resultData
                .flatMap { data -> Result<BusStop, HttpClientError> in
                    guard let busStop = try? JSONDecoder().decode(BusStop.self, from: data) else {
                        return .failure(.unknown(TfLWrapperDefaultError.jsonParsingError))
                    }
                    return .success(busStop)
                }
                .mapError(Self.tflWrapperError(from:))
            completion(resultBusStop)
        }
    }

    public func arrivalsInSeconds(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<[Int], TfLWrapperError>) -> Void
    ) {
//        Thread.sleep(forTimeInterval: 4)
//        completion(.success([20, 250, 300, 400, 500, 600]))

//        completion(.failure(.generic(TfLWrapperDefaultError.jsonParsingError)))

        let path = "\(baseURL)v1/bus-stops/\(stopId)/lines/\(lineId)"
        httpClient.fetch(path: path) { resultData in
            let resultArrivals = resultData
                .flatMap { data -> Result<[Int], HttpClientError> in
                    guard let response = try? JSONDecoder().decode(ArrivalsResponse.self, from: data) else {
                        return .failure(.unknown(TfLWrapperDefaultError.jsonParsingError))
                    }
                    return .success(response.arrivalsInSeconds)
                }
                .mapError(Self.tflWrapperError(from:))
            completion(resultArrivals)
        }
    }

    private static func tflWrapperError(from httpClientError: HttpClientError) -> TfLWrapperError {
        switch httpClientError {
        case let .unknown(error):
            return .generic(error)
        case .invalidPath, .httpStatus:
            return .generic(httpClientError)
        }
    }
}
