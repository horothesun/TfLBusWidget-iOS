public final class MostRelevantArrivalsInMinutesUseCaseDecorator {

    private let baseUseCase: ArrivalsInMinutesUseCase

    public init(baseUseCase: ArrivalsInMinutesUseCase) {
        self.baseUseCase = baseUseCase
    }
}

extension MostRelevantArrivalsInMinutesUseCaseDecorator: ArrivalsInMinutesUseCase {
    public func arrivalsInMinutes(
        stopId: String,
        lineId: String,
        completion: @escaping (Result<[Int], Error>) -> Void
    ) {
        baseUseCase.arrivalsInMinutes(stopId: stopId, lineId: lineId) { resultArrivalsInMinutes in
            completion(resultArrivalsInMinutes.map { Array($0.prefix(4)) })
        }
    }
}
