import WidgetUseCases

final class MockTfLWrapper: TfLWrapper {

    var busStopFromIdWithCompletion: (
        (_ stopId: String,
         _ completion: @escaping (Result<BusStop, TfLWrapperError>) -> Void
        ) -> Void
    )?
    var arrivalsInSecondsFromStopIdLineIdWithCompletion: (
        (_ stopId: String,
         _ lineId: String,
         _ completion: @escaping (Result<[Int], TfLWrapperError>) -> Void
        ) -> Void
    )?

    func busStop(stopId: String, completion: @escaping (Result<BusStop, TfLWrapperError>) -> Void) {
        busStopFromIdWithCompletion?(stopId, completion)
    }

    func arrivalsInSeconds(stopId: String, lineId: String, completion: @escaping (Result<[Int], TfLWrapperError>) -> Void) {
        arrivalsInSecondsFromStopIdLineIdWithCompletion?(stopId, lineId, completion)
    }
}
