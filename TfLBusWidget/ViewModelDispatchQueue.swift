import TfLBusRepository
import Dispatch

struct ViewModelDispatchQueue {

    private typealias `Self` = ViewModelDispatchQueue

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let displayModelBuilder: DisplayModelBuilder
    private let processingQueue: DispatchQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        displayModelBuilder: DisplayModelBuilder,
        processingQueue: DispatchQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.displayModelBuilder = displayModelBuilder
        self.processingQueue = processingQueue
    }
}

extension ViewModelDispatchQueue: ViewModel {

    private static var openAppMessage: String { return "Open the 'TfL Bus' app 👍" }

    func getDisplayModel(
        start:  @escaping () -> Void,
        success: @escaping (DisplayModel) -> Void,
        failure: @escaping (ErrorDisplayModel) -> Void
    ) {
        DispatchQueue.main.async(execute: start)

        processingQueue.async { [userConfiguration, tflWrapper, displayModelBuilder] in
            guard
                let stopId = userConfiguration.stopId,
                let lineId = userConfiguration.lineId
            else {
                DispatchQueue.main.async { failure(.init(message: Self.openAppMessage)) }
                return
            }

            tflWrapper.busStop(stopId: stopId) { resultBusStop in
                tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId) { resultArrivals in
                    let resultDisplayModel = displayModelBuilder.displayModelFrom(
                        lineId: lineId,
                        resultBusStop: resultBusStop,
                        resultArrivalsInSeconds: resultArrivals
                    )
                    DispatchQueue.main.async(
                        execute: Self.completion(for: resultDisplayModel, success, failure)
                    )
                }
            }
        }
    }

    private static func completion(
        for resultDisplayModel: Result<DisplayModel, ErrorDisplayModel>,
        _ success: @escaping (DisplayModel) -> Void,
        _ failure: @escaping (ErrorDisplayModel) -> Void
    ) -> () -> Void {
        return { resultDisplayModel.fold(success: success, failure: failure) }
    }
}
