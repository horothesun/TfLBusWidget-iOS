import Foundation
import HttpClientLib

final class MockURLSessionProtocol: URLSessionProtocol {

    var dataTaskResult = MockURLSessionDataTask()
    private(set) var lastRequest: URLRequest?

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        lastRequest = request
        return dataTaskResult
    }
}
