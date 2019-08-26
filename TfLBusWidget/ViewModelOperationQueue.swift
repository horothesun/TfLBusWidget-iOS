import Foundation
import TfLBusOperations
import TfLBusRepository

struct ViewModelOperationQueue {

    private typealias `Self` = ViewModelOperationQueue
    private typealias ResultBusStop = Result<BusStop, TfLWrapperError>
    private typealias ResultArrivals = Result<[Int], TfLWrapperError>
    private typealias ResultDisplayModel = Result<DisplayModel, ErrorDisplayModel>
    private typealias MakeDisplayModelOperation = Input2OutputOperation<ResultBusStop, ResultArrivals, ResultDisplayModel>

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let displayModelBuilder: DisplayModelBuilder
    private let processingQueue: OperationQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        displayModelBuilder: DisplayModelBuilder,
        processingQueue: OperationQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.displayModelBuilder = displayModelBuilder
        self.processingQueue = processingQueue
    }
}

extension ViewModelOperationQueue: ViewModel {

    private static var openAppMessage: String { return "Open the 'TfL Bus' app 👍" }
    private static var errorMessage: String { return "Oops, an error occurred 🙏" }

    func getDisplayModel(
        start: @escaping () -> Void,
        success: @escaping (DisplayModel) -> Void,
        failure: @escaping (ErrorDisplayModel) -> Void
    ) {
        OperationQueue.main.addOperation(start)

        guard
            let stopId = userConfiguration.stopId,
            let lineId = userConfiguration.lineId
        else {
            OperationQueue.main.addOperation { failure(.init(message: Self.openAppMessage)) }
            return
        }

        let getBusStop = OutputOperation<ResultBusStop> { [tflWrapper] recordOutput in
            tflWrapper.busStop(stopId: stopId, completion: recordOutput)
        }
        let getArrivals = OutputOperation<ResultArrivals> { [tflWrapper] recordOutput in
            tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId, completion: recordOutput)
        }
        let makeDisplayModel = Self.makeDisplayModelOperation(
            lineId: lineId,
            getBusStop: getBusStop,
            getArrivals: getArrivals,
            success: success,
            failure: failure,
            displayModelBuilder: displayModelBuilder
        )
        let adapter = BlockOperation { [weak getBusStop, weak getArrivals, weak makeDisplayModel] in
            makeDisplayModel?.input1 = getBusStop?.output
            makeDisplayModel?.input2 = getArrivals?.output
        }

        adapter.addDependencies(getBusStop, getArrivals)
        makeDisplayModel.addDependency(adapter)

        processingQueue.addOperations(
            [getBusStop, getArrivals, adapter, makeDisplayModel],
            waitUntilFinished: false
        )
    }

    private static func makeDisplayModelOperation(
        lineId: String,
        getBusStop: OutputOperation<ResultBusStop>,
        getArrivals: OutputOperation<ResultArrivals>,
        success: @escaping (DisplayModel) -> Void,
        failure: @escaping (ErrorDisplayModel) -> Void,
        displayModelBuilder: DisplayModelBuilder
    ) -> MakeDisplayModelOperation {
        let makeDisplayModel = MakeDisplayModelOperation { recordOutput in
            let resultDisplayModel = displayModelBuilder.displayModelFrom(
                lineId: lineId,
                resultBusStop: getBusStop.output,
                resultArrivalsInSeconds: getArrivals.output
            )
            recordOutput(resultDisplayModel)
        }
        makeDisplayModel.completionBlock = { [weak makeDisplayModel] in
            guard let resultDisplayModel = makeDisplayModel?.output else {
                OperationQueue.main.addOperation { failure(.init(message: errorMessage)) }
                return
            }

            OperationQueue.main.addOperation(
                completion(for: resultDisplayModel, success, failure)
            )
        }
        return makeDisplayModel
    }

    private static func completion(
        for resultDisplayModel: ResultDisplayModel,
        _ success: @escaping (DisplayModel) -> Void,
        _ failure: @escaping (ErrorDisplayModel) -> Void
    ) -> () -> Void {
        return { resultDisplayModel.fold(success: success, failure: failure) }
    }
}
