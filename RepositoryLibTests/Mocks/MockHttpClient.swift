import Foundation
import HttpClientLib

final class MockHttpClient: HttpClient {

    var fetchFromPathWithCompletion: (
        (_ path: String,
         _ completion: @escaping (Result<Data, HttpClientError>) -> Void
        ) -> Void
    )?

    func fetch(path: String, completion: @escaping (Result<Data, HttpClientError>) -> Void) {
        guard let fetchFromPathWithCompletion = fetchFromPathWithCompletion else {
            fatalError("\(#function): stub not defined")
        }

        fetchFromPathWithCompletion(path, completion)
    }
}
