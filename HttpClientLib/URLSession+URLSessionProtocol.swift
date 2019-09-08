import Foundation

extension URLSession: URLSessionProtocol {
    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        return (
            dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
        ) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
