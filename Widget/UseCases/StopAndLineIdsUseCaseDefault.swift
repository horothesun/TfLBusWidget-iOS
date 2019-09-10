public final class StopAndLineIdsUseCaseDefault {

    private let userConfiguration: UserConfiguration

    public init(userConfiguration: UserConfiguration) {
        self.userConfiguration = userConfiguration
    }
}

extension StopAndLineIdsUseCaseDefault: StopAndLineIdsUseCase {

    public func stopAndLineIds() -> (String, String)? {
        guard
            let stopId = userConfiguration.stopId,
            let lineId = userConfiguration.lineId
        else {
            return nil
        }

        return (stopId, lineId)
    }
}
