import TfLBusRepository
import Foundation

final class GetBusStopOperation: AsyncOperation {

    // output
    var resultBusStop: Result<BusStop, TfLWrapperError>?

    private let stopId: String
    private let tflWrapper: TfLWrapper

    init(
        stopId: String,
        tflWrapper: TfLWrapper
    ) {
        self.stopId = stopId
        self.tflWrapper = tflWrapper
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        executing(true)

        tflWrapper.busStop(stopId: stopId) { [weak self] resultBusStop in
            self?.resultBusStop = resultBusStop
            self?.executing(false)
            self?.finish(true)
        }
    }
}
