public final class BusStopUseCaseDefault {

    private let tflWrapper: TfLWrapper

    public init(tflWrapper: TfLWrapper) {
        self.tflWrapper = tflWrapper
    }
}

extension BusStopUseCaseDefault: BusStopUseCase {
    public func busStop(stopId: String, completion: @escaping (Result<BusStop, Error>) -> Void) {
        tflWrapper.busStop(stopId: stopId) { resultBusStop in
            completion(resultBusStop.mapError { $0 as Error })
        }
    }
}
