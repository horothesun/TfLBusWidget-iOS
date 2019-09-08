import Dispatch
import RepositoryLib

final class ViewModelDispatchQueue {

    private typealias `Self` = ViewModelDispatchQueue

    private let userConfiguration: UserConfiguration
    private let tflWrapper: TfLWrapper
    private let arrivalsFormatter: ArrivalsFormatter
    private let processingQueue: DispatchQueue

    init(
        userConfiguration: UserConfiguration,
        tflWrapper: TfLWrapper,
        arrivalsFormatter: ArrivalsFormatter,
        processingQueue: DispatchQueue
    ) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
        self.arrivalsFormatter = arrivalsFormatter
        self.processingQueue = processingQueue
    }
}

extension ViewModelDispatchQueue: ViewModel {

    private static var openAppMessage: String { return "Open the 'TfL Bus' app 👍" }
    private static var errorMessage: String { return "Oops, an error occurred 🙏" }

    func getDisplayModel(
        start:  @escaping () -> Void,
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void
    ) {
        DispatchQueue.main.async(execute: start)

        processingQueue.async { [userConfiguration, tflWrapper, arrivalsFormatter] in
            guard
                let stopId = userConfiguration.stopId,
                let lineId = userConfiguration.lineId
            else {
                DispatchQueue.main.async { failure(.init(message: Self.openAppMessage)) }
                return
            }

            // sequential calls ☹️
            tflWrapper.busStop(stopId: stopId) { resultBusStop in
                tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId) { resultArrivals in
                    let resultDisplayModel = Self.displayModelFrom(
                        lineId: lineId,
                        resultBusStop: resultBusStop,
                        resultArrivalsInSeconds: resultArrivals,
                        arrivalsFormatter: arrivalsFormatter
                    )
                    DispatchQueue.main.async { resultDisplayModel.fold(success: success, failure: failure) }
                }
            }
        }
    }

    private static func displayModelFrom(
        lineId: String,
        resultBusStop: Result<BusStop, TfLWrapperError>?,
        resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?,
        arrivalsFormatter: ArrivalsFormatter
    ) -> Result<SuccessDisplayModel, FailureDisplayModel> {
        guard
            let resultBusStop = resultBusStop,
            let resultArrivalsInSeconds = resultArrivalsInSeconds,
            case let .success(busStop) = resultBusStop,
            case let .success(arrivalsInSeconds) = resultArrivalsInSeconds
        else {
            return .failure(.init(message: Self.errorMessage))
        }

        return .success(
            .init(
                busStopCode: busStop.streetCode,
                busStopName: busStop.stopName,
                line: lineId.uppercased(),
                arrivals: arrivalsFormatter.arrivalsText(from: arrivalsInSeconds)
            )
        )
    }
}
