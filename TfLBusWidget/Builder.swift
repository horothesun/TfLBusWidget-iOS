import TfLBusRepository
import Dispatch
import Foundation

enum Builder {
    static func makeViewModel() -> ViewModel {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .userInitiated

        return ViewModelOperationQueue(
            userConfiguration: TfLBusRepository.Builder.makeUserConfiguration(),
            tflWrapper: TfLBusRepository.Builder.makeTfLWrapper(),
            arrivalsTextFormatter: ArrivalsTextFormatterDefault(),
            processingQueue: operationQueue
        )
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
