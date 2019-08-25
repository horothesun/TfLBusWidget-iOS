public final class OutputOperation<O>: AsyncOperation {

    public var output: O?

    private let wrapped: (@escaping (O) -> Void) -> Void

    public init(wrapping: @escaping (@escaping (O) -> Void) -> Void) {
        self.wrapped = wrapping
    }

    override public func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        executing(true)

        wrapped { [weak self] result in
            self?.output = result
            self?.executing(false)
            self?.finish(true)
        }
    }
}
