public final class StopAndLineIdsSetterUseCaseDefault {

    private var userConfiguration: UserConfiguration

    public init(userConfiguration: UserConfiguration) {
        self.userConfiguration = userConfiguration
    }
}

extension StopAndLineIdsSetterUseCaseDefault: StopAndLineIdsSetterUseCase {

    public func set(stopId: String?) { userConfiguration.stopId = stopId }

    public func set(lineId: String?) { userConfiguration.lineId = lineId }
}
