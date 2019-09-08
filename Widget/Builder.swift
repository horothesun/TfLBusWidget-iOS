import Foundation
import WidgetFeature
import HttpClientLib
import RepositoryLib

enum Builder {

    // DispatchQueue-based implementation
    static func makeViewModel_() -> ViewModel {
        return ViewModelDispatchQueue(
            userConfiguration: makeUserConfiguration(),
            tflWrapper: makeTfLWrapper(),
            arrivalsFormatter: ArrivalsFormatterDefault(),
            processingQueue: .global(qos: .userInitiated)
        )
    }

    // OperationQueue-based implementation
    static func makeViewModel() -> ViewModel {
        return ViewModelOperationQueue(
            userConfiguration: makeUserConfiguration(),
            tflWrapper: makeTfLWrapper(),
            arrivalsFormatter: ArrivalsFormatterDefault(),
            processingQueue: makeConcurrentQueue()
        )
    }

    private static func makeTfLWrapper() -> TfLWrapper {
        let httpClient = HttpClientURLSession(urlSession: URLSession.shared)
        return TfLWrapperDefault(httpClient: httpClient)
    }

    private static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }

    private static func makeConcurrentQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }
}
