import Foundation

class AsyncOperation: Operation {

    private let isExecutingKey = "isExecuting"
    private let isFinishedKey = "isFinished"

    func executing(_ executing: Bool) { _executing = executing }

    func finish(_ finished: Bool) { _finished = finished }

    private var _executing = false {
        willSet { willChangeValue(forKey: isExecutingKey) }
        didSet { didChangeValue(forKey: isExecutingKey) }
    }

    override var isExecuting: Bool { return _executing }

    private var _finished = false {
        willSet { willChangeValue(forKey: isFinishedKey) }
        didSet { didChangeValue(forKey: isFinishedKey) }
    }

    override var isFinished: Bool { return _finished }
}
