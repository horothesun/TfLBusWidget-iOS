import TfLBusRepository
import Foundation

final class GetArrivalsOperation: AsyncOperation {

    // output
    var resultArrivalsInSeconds: Result<[Int], TfLWrapperError>?

    private let stopId: String
    private let lineId: String
    private let tflWrapper: TfLWrapper

    init(
        stopId: String,
        lineId: String,
        tflWrapper: TfLWrapper
    ) {
        self.stopId = stopId
        self.lineId = lineId
        self.tflWrapper = tflWrapper
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        executing(true)

        tflWrapper.arrivalsInSeconds(stopId: stopId, lineId: lineId) { [weak self] resultArrivalsInSeconds in
            self?.resultArrivalsInSeconds = resultArrivalsInSeconds
            self?.executing(false)
            self?.finish(true)
        }
    }
}
