public final class Input2OutputOperation<I1, I2, O>: AsyncOperation {

    // inputs
    public var input1: I1?
    public var input2: I2?

    // output
    public var output: O?

    private let wrapped: (_ recordOutput: @escaping (O) -> Void) -> Void

    public init(wrapping: @escaping (_ recordOutput: @escaping (O) -> Void) -> Void) {
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
