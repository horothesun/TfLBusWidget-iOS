import Foundation

public class AsyncOperation: Operation {

    private let isExecutingKey = "isExecuting"
    private let isFinishedKey = "isFinished"

    public func executing(_ executing: Bool) { _executing = executing }

    public func finish(_ finished: Bool) { _finished = finished }

    private var _executing = false {
        willSet { willChangeValue(forKey: isExecutingKey) }
        didSet { didChangeValue(forKey: isExecutingKey) }
    }

    override public var isExecuting: Bool { return _executing }

    private var _finished = false {
        willSet { willChangeValue(forKey: isFinishedKey) }
        didSet { didChangeValue(forKey: isFinishedKey) }
    }

    override public var isFinished: Bool { return _finished }
}
