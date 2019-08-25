import TfLBusRepository
//import Dispatch
import Foundation

enum Builder {

    static func makeViewModel() -> ViewModel {
        return ViewModelOperationQueue(
            userConfiguration: TfLBusRepository.Builder.makeUserConfiguration(),
            tflWrapper: TfLBusRepository.Builder.makeTfLWrapper(),
            arrivalsTextFormatter: ArrivalsTextFormatterDefault(),
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
//            arrivalsTextFormatter: ArrivalsTextFormatterDefault(),
//            processingQueue: DispatchQueue.global(qos: .userInitiated)
//        )
//    }
}
