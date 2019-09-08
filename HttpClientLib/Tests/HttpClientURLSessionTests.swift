import XCTest
@testable import HttpClientLib

final class HttpClientURLSessionTests: XCTestCase {

    private weak var weakHttpClient: HttpClientURLSession!
    private weak var weakURLSession: MockURLSessionProtocol!

    override func tearDown() {
        assertHttpClientNotLeaking()
        assertURLSessionNotLeaking()
    }
}

extension HttpClientURLSessionTests {
    func test_fetchFails_withInvalidPath() {
        let (urlSessionMock, httpClient) = makeHttpClient()
        let resultDataExpectation = XCTestExpectation(description: "result data must be a failure")
        httpClient.fetch(path: "") { resultData in
            if case .failure(.invalidPath) = resultData { resultDataExpectation.fulfill() }
        }
        XCTAssertNil(urlSessionMock.lastRequest)
        XCTAssertFalse(urlSessionMock.dataTaskResult.wasResumeCalled)
    }

    func test_fetchForwardsToURLSession_whenPathIsValid() {
        let (urlSessionMock, httpClient) = makeHttpClient()
        let path = "abc.org"
        httpClient.fetch(path: path) { _ in }
        XCTAssertEqual(urlSessionMock.lastRequest?.url?.absoluteString, path)
        XCTAssert(urlSessionMock.dataTaskResult.wasResumeCalled)
    }
}

extension HttpClientURLSessionTests {
    private func assertHttpClientNotLeaking() {
        XCTAssertNil(weakHttpClient)
    }

    private func assertURLSessionNotLeaking() {
        XCTAssertNil(weakURLSession)
    }

    private func makeHttpClient() -> (MockURLSessionProtocol, HttpClientURLSession) {
        let urlSessionMock = MockURLSessionProtocol()
        let httpClient = HttpClientURLSession(urlSession: urlSessionMock)
        weakHttpClient = httpClient
        weakURLSession = urlSessionMock
        return (urlSessionMock, httpClient)
    }
}
