public struct SuccessDisplayModel {
    public let busStopCode: String
    public let busStopName: String
    public let line: String
    public let arrivals: String
}

public struct FailureDisplayModel: Error {
    public let message: String
}

public protocol ViewModel {
    func getDisplayModel(
        start: @escaping () -> Void,
        success: @escaping (SuccessDisplayModel) -> Void,
        failure: @escaping (FailureDisplayModel) -> Void
    )
}

public protocol ArrivalsFormatter {
    func arrivalsText(from arrivalsInMinutes: [Int]) -> String
}
