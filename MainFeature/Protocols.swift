public protocol MainViewModel {
    var title: String { get }

    func update(stopId: String)
    func cleanStopId()
    func update(lineId: String)
    func cleanLineId()
}

public protocol TfLWrapper { }

public protocol UserConfiguration {
    var stopId: String? { get set }
    var lineId: String? { get set }
}
