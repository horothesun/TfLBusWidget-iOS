import XCTest
import OperationsLib

final class Input2OutputOperationTests: XCTestCase {

    private weak var weakOperation: Input2OutputOperation<Int, Int, Int>!

    override func tearDown() {
        assertOperationNotLeaking()
    }
}

extension Input2OutputOperationTests {
    func test_main_notRecordingOutput_mustStoreNothing() {
        let expectation = XCTestExpectation(description: "must call wrapped closure")
        let operation = makeOperationInt { recordOutput in
            expectation.fulfill()
        }
        operation.main()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNil(operation.output)
    }

    func test_main_recordingOutput_mustStoreOutput() {
        let output = 123
        let expectation = XCTestExpectation(description: "must call wrapped closure")
        let operation = makeOperationInt { recordOutput in
            recordOutput(output)
            expectation.fulfill()
        }
        operation.main()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(operation.output, output)
    }

    func test_main_recordingOutputWhenCancelled_mustStoreNothing() {
        let output = 123
        let expectation = XCTestExpectation(description: "must call wrapped closure")
        expectation.isInverted = true
        let operation = makeOperationInt { recordOutput in
            recordOutput(output)
            expectation.fulfill()
        }
        operation.cancel()
        operation.main()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNil(operation.output)
    }
}

extension Input2OutputOperationTests {
    private func makeOperationInt(
        wrapped: @escaping (_ recordOutput: @escaping (Int) -> Void) -> Void
    ) -> Input2OutputOperation<Int, Int, Int> {
        let operation = Input2OutputOperation<Int, Int, Int>(wrapping: wrapped)
        weakOperation = operation
        return operation
    }

    private func assertOperationNotLeaking() {
        XCTAssertNil(weakOperation)
    }
}
