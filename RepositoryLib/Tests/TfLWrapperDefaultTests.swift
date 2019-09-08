import XCTest
@testable import WidgetFeature
@testable import RepositoryLib

final class TfLWrapperDefaultTests: XCTestCase {

    private weak var weakTfLWrapper: TfLWrapperDefault!
    private weak var weakHttpClient: MockHttpClient!

    override func tearDown() {
        assertTfLWrapperNotLeaking()
        assertHttpClientNotLeaking()
    }
}

// MARK:- busStop(stopId:completion:)

extension TfLWrapperDefaultTests {
    func test_busStopFails_whenHttpClient500s() {
        let (httpClientMock, tflWrapper) = makeTfLWrapper()
        let httpClientError: HttpClientError = .httpStatus(500)
        httpClientMock.fetchFromPathWithCompletion = { _, completion in
            completion(.failure(httpClientError))
        }
        let resultBusStopExpectation = XCTestExpectation(description: "result bus-stop must be a failure")
        tflWrapper.busStop(stopId: "stopId") { resultBusStop in
            if case let .failure(.generic(genericError)) = resultBusStop,
                let error = genericError as? HttpClientError,
                error == httpClientError {
                resultBusStopExpectation.fulfill()
            }
        }
        wait(for: [resultBusStopExpectation], timeout: 0.1)
    }

    func test_busStopFails_whenResponseNotParsable() {
        let (httpClientMock, tflWrapper) = makeTfLWrapper()
        let busStopData = Data()
        httpClientMock.fetchFromPathWithCompletion = { _, completion in
            completion(.success(busStopData))
        }
        let resultBusStopExpectation = XCTestExpectation(description: "result bus-stop must be a failure")
        tflWrapper.busStop(stopId: "stopId") { resultBusStop in
            if case let .failure(.generic(genericError)) = resultBusStop,
                let error = genericError as? TfLWrapperDefault.TfLWrapperDefaultError,
                case .jsonParsingError = error {
                resultBusStopExpectation.fulfill()
            }
        }
        wait(for: [resultBusStopExpectation], timeout: 0.1)
    }
    
    func test_busStopSucceeds_whenHttpClientSucceeds() {
        let (httpClientMock, tflWrapper) = makeTfLWrapper()
        let expectedBusStop = BusStop(id: "490000119F",streetCode: "F", stopName: "HYDE PARK CORNER")
        let busStopData = try! JSONEncoder().encode(expectedBusStop)
        httpClientMock.fetchFromPathWithCompletion = { _, completion in
            completion(.success(busStopData))
        }
        let resultBusStopExpectation = XCTestExpectation(description: "result bus-stop must be a success")
        tflWrapper.busStop(stopId: "stopId") { resultBusStop in
            if case let .success(busStop) = resultBusStop,
                busStop.id == expectedBusStop.id,
                busStop.streetCode == expectedBusStop.streetCode,
                busStop.stopName == expectedBusStop.stopName {
                resultBusStopExpectation.fulfill()
            }
        }
        wait(for: [resultBusStopExpectation], timeout: 0.1)
    }
}

// MARK:- arrivalsInSeconds(stopId:lineId:completion:)

extension TfLWrapperDefaultTests {
    func test_arrivalsInSecondsFails_whenHttpClient500s() {
        let (httpClientMock, tflWrapper) = makeTfLWrapper()
        let httpClientError: HttpClientError = .httpStatus(500)
        httpClientMock.fetchFromPathWithCompletion = { _, completion in
            completion(.failure(httpClientError))
        }
        let resultArrivalsExpectation = XCTestExpectation(description: "result arrivals must be a failure")
        tflWrapper.arrivalsInSeconds(stopId: "stopId", lineId: "lineId") { resultArrivalsInSeconds in
            if case let .failure(.generic(genericError)) = resultArrivalsInSeconds,
                let error = genericError as? HttpClientError,
                error == httpClientError {
                resultArrivalsExpectation.fulfill()
            }
        }
        wait(for: [resultArrivalsExpectation], timeout: 0.1)
    }

    func test_arrivalsInSecondsFails_whenResponseNotParsable() {
        let (httpClientMock, tflWrapper) = makeTfLWrapper()
        let arrivalsResponseData = Data()
        httpClientMock.fetchFromPathWithCompletion = { _, completion in
            completion(.success(arrivalsResponseData))
        }
        let resultArrivalsExpectation = XCTestExpectation(description: "result bus-stop must be a failure")
        tflWrapper.arrivalsInSeconds(stopId: "stopId", lineId: "lineId") { resultArrivalsInSeconds in
            if case let .failure(.generic(genericError)) = resultArrivalsInSeconds,
                let error = genericError as? TfLWrapperDefault.TfLWrapperDefaultError,
                case .jsonParsingError = error {
                resultArrivalsExpectation.fulfill()
            }
        }
        wait(for: [resultArrivalsExpectation], timeout: 0.1)
    }

    func test_arrivalsInSecondsSucceeds_whenHttpClientSucceeds() {
        let (httpClientMock, tflWrapper) = makeTfLWrapper()
        let expectedArrivalsResponse = ArrivalsResponse(
            stopId: "490000119F",
            lineId: "38",
            arrivalsInSeconds: [10, 60, 119, 121]
        )
        let arrivalsResponseData = try! JSONEncoder().encode(expectedArrivalsResponse)
        httpClientMock.fetchFromPathWithCompletion = { _, completion in
            completion(.success(arrivalsResponseData))
        }
        let resultArrivalsExpectation = XCTestExpectation(description: "result arrivals must be a success")
        tflWrapper.arrivalsInSeconds(stopId: "stopId", lineId: "lineId") { resultArrivalsInSeconds in
            if case let .success(arrivalsInSeconds) = resultArrivalsInSeconds,
                arrivalsInSeconds == expectedArrivalsResponse.arrivalsInSeconds {
                resultArrivalsExpectation.fulfill()
            }
        }
        wait(for: [resultArrivalsExpectation], timeout: 0.1)
    }
}

extension TfLWrapperDefaultTests {
    private func assertTfLWrapperNotLeaking() {
        XCTAssertNil(weakTfLWrapper)
    }

    private func assertHttpClientNotLeaking() {
        XCTAssertNil(weakHttpClient)
    }

    private func makeTfLWrapper() -> (MockHttpClient, TfLWrapperDefault) {
        let httpClientMock = MockHttpClient()
        let tflWrapper = TfLWrapperDefault(httpClient: httpClientMock)
        weakTfLWrapper = tflWrapper
        weakHttpClient = httpClientMock
        return (httpClientMock, tflWrapper)
    }
}
