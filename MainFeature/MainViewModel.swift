public final class MainViewModelDefault {

    private var userConfiguration: UserConfiguration
    private var tflWrapper: TfLWrapper

    public init(userConfiguration: UserConfiguration, tflWrapper: TfLWrapper) {
        self.userConfiguration = userConfiguration
        self.tflWrapper = tflWrapper
    }
}

extension MainViewModelDefault: MainViewModel {

    public var title: String { return  "TfL Bus" }

    public func update(stopId: String) { userConfiguration.stopId = stopId }

    public func cleanStopId() { userConfiguration.stopId = nil }

    public func update(lineId: String) { userConfiguration.lineId = lineId }

    public func cleanLineId() { userConfiguration.lineId = nil }
}
