import Foundation
import WidgetViewModel
import WidgetUseCases
import RepositoryLib
import HttpClientLib

enum Builder {

    static func makeViewModel() -> ViewModel {
        return ViewModelDefault(
            stopAndLineIdsUseCase: makeStopAndLineIdsUseCase(),
            busStopAndArrivalsInMinutesUseCase: makeBusStopAndArrivalsInMinutesUseCase(),
            arrivalsFormatter: ArrivalsFormatterDefault(),
            processingQueue: .global(qos: .userInitiated)
        )
    }

    // DispatchQueue-based implementation
//    static func makeViewModel() -> ViewModel {
//        let tflWrapper = makeTfLWrapper()
//        return ViewModelDispatchQueue(
//            stopAndLineIdsUseCase: makeStopAndLineIdsUseCase(),
//            busStopUseCase: BusStopUseCaseDefault(tflWrapper: tflWrapper),
//            arrivalsInMinutesUseCase: makeArrivalsInMinutesUseCase(tflWrapper: tflWrapper),
//            arrivalsFormatter: ArrivalsFormatterDefault(),
//            processingQueue: .global(qos: .userInitiated)
//        )
//    }

    // OperationQueue-based implementation
//    static func makeViewModel() -> ViewModel {
//        let tflWrapper = makeTfLWrapper()
//        return ViewModelOperationQueue(
//            stopAndLineIdsUseCase: makeStopAndLineIdsUseCase(),
//            busStopUseCase: BusStopUseCaseDefault(tflWrapper: tflWrapper),
//            arrivalsInMinutesUseCase: makeArrivalsInMinutesUseCase(tflWrapper: tflWrapper),
//            arrivalsFormatter: ArrivalsFormatterDefault(),
//            processingQueue: makeConcurrentQueue()
//        )
//    }

    private static func makeStopAndLineIdsUseCase() -> StopAndLineIdsUseCase {
        return StopAndLineIdsUseCaseDefault(userConfiguration: makeUserConfiguration())
    }

    private static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }

    private static func makeBusStopAndArrivalsInMinutesUseCase() -> BusStopAndArrivalsInMinutesUseCase {
        let tflWrapper = makeTfLWrapper()
        // Sequential implementation
//        return BusStopAndArrivalsInMinutesUseCaseSequential(
//            busStopUseCase: BusStopUseCaseDefault(tflWrapper: tflWrapper),
//            arrivalsInMinutesUseCase: makeArrivalsInMinutesUseCase(tflWrapper: tflWrapper)
//        )

        // OperationQueue-based implementation
        return BusStopAndArrivalsInMinutesUseCaseOperationQueue(
            busStopUseCase: BusStopUseCaseDefault(tflWrapper: tflWrapper),
            arrivalsInMinutesUseCase: makeArrivalsInMinutesUseCase(tflWrapper: tflWrapper),
            processingQueue: makeConcurrentQueue()
        )
    }

    private static func makeArrivalsInMinutesUseCase(tflWrapper: TfLWrapper) -> ArrivalsInMinutesUseCase {
        return MostRelevantArrivalsInMinutesUseCaseDecorator(
            baseUseCase: ArrivalsInMinutesUseCaseDefault(tflWrapprer: tflWrapper)
        )
    }

    private static func makeTfLWrapper() -> TfLWrapper {
        let httpClient = HttpClientURLSession(urlSession: URLSession.shared)
        return TfLWrapperDefault(httpClient: httpClient)
    }

    private static func makeConcurrentQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }
}
