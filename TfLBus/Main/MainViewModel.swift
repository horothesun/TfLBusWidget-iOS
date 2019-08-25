import TfLBusRepository

protocol MainViewModel {
    var title: String { get }

    func update(stopId: String)
    func cleanStopId()
    func update(lineId: String)
    func cleanLineId()
}

final class MainViewModelDefault {

    private var userConfiguration: UserConfiguration

    init(userConfiguration: UserConfiguration) {
        self.userConfiguration = userConfiguration
    }
}

extension MainViewModelDefault: MainViewModel {

    var title: String { return  "TfL Bus" }

    func update(stopId: String) { userConfiguration.stopId = stopId }

    func cleanStopId() { userConfiguration.stopId = nil }

    func update(lineId: String) { userConfiguration.lineId = lineId }

    func cleanLineId() { userConfiguration.lineId = nil }
}
