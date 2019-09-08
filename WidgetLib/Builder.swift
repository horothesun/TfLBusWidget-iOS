import Foundation
import RepositoryLib

public enum Builder {

    // DispatchQueue-based implementation
//    public static func makeViewModel(httpClient: HttpClient) -> ViewModel {
//        return ViewModelDispatchQueue(
//            userConfiguration: RepositoryLib.Builder.makeUserConfiguration(),
//            tflWrapper: RepositoryLib.Builder.makeTfLWrapper(httpClient: httpClient),
//            arrivalsFormatter: ArrivalsFormatterDefault(),
//            processingQueue: .global(qos: .userInitiated)
//        )
//    }

    // OperationQueue-based implementation
    public static func makeViewModel(httpClient: HttpClient) -> ViewModel {
        return ViewModelOperationQueue(
            userConfiguration: RepositoryLib.Builder.makeUserConfiguration(),
            tflWrapper: RepositoryLib.Builder.makeTfLWrapper(httpClient: httpClient),
            arrivalsFormatter: ArrivalsFormatterDefault(),
            processingQueue: makeConcurrentQueue()
        )
    }

    private static func makeConcurrentQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }
}
