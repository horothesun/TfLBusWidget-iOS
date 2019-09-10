public final class ArrivalsInMinutesUseCaseDefault {

    private let tflWrapprer: TfLWrapper

    public init(tflWrapprer: TfLWrapper) {
        self.tflWrapprer = tflWrapprer
    }
}

extension ArrivalsInMinutesUseCaseDefault: ArrivalsInMinutesUseCase {

    public func arrivalsInMinutes(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<[Int], Error>) -> Void
    ) {
        tflWrapprer.arrivalsInSeconds(stopId: stopId, lineId: lineId) { resultArrivalsInSeconds in
            let resultArrivalsInMinutes = resultArrivalsInSeconds
                .map { arrivalsInSeconds in
                    arrivalsInSeconds.map { seconds in seconds / 60 }
                }
                .mapError { $0 as Error }
            completion(resultArrivalsInMinutes)
        }
    }
}
