import Foundation
//import Dispatch
import TfLBusRepository

enum Builder {

    static func makeViewModel() -> ViewModel {
        return ViewModelOperationQueue(
            userConfiguration: TfLBusRepository.Builder.makeUserConfiguration(),
            tflWrapper: TfLBusRepository.Builder.makeTfLWrapper(),
            displayModelBuilder: DisplayModelBuilderDefault(),
            processingQueue: makeConcurrentQueue()
        )
    }

    private static func makeConcurrentQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }

//    static func makeViewModel() -> ViewModel {
//        return ViewModelDispatchQueue(
//            userConfiguration: TfLBusRepository.Builder.makeUserConfiguration(),
//            tflWrapper: TfLBusRepository.Builder.makeTfLWrapper(),
//            displayModelBuilder: DisplayModelBuilderDefault(),
//            processingQueue: DispatchQueue.global(qos: .userInitiated)
//        )
//    }
}
