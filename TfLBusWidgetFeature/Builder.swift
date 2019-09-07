import Foundation
import TfLBusRepository

public enum Builder {

    // DispatchQueue-based implementation
//    public static func makeViewModel() -> ViewModel {
//        return ViewModelDispatchQueue(
//            userConfiguration: TfLBusRepository.Builder.makeUserConfiguration(),
//            tflWrapper: TfLBusRepository.Builder.makeTfLWrapper(),
//            arrivalsFormatter: ArrivalsFormatterDefault(),
//            processingQueue: .global(qos: .userInitiated)
//        )
//    }

    // OperationQueue-based implementation
    public static func makeViewModel() -> ViewModel {
        return ViewModelOperationQueue(
            userConfiguration: TfLBusRepository.Builder.makeUserConfiguration(),
            tflWrapper: TfLBusRepository.Builder.makeTfLWrapper(),
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
