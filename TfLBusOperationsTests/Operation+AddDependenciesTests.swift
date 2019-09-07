import XCTest
import TfLBusOperations

final class Operation_AddDependenciesTests: XCTestCase {

    private weak var weakOperation: Operation!

    override func tearDown() {
        assertOperationNotLeaking()
    }

    func test_addDependencies() {
        let operation = makeOperation()
        let dependencyA = IdentifiableOperation(id: "A")
        let dependencyB = IdentifiableOperation(id: "B")
        let dependencyC = IdentifiableOperation(id: "C")
        operation.addDependencies(dependencyA, dependencyB, dependencyC)
        guard operation.dependencies.count == 3 else {
            XCTFail("dependencies must be 3, (found \(operation.dependencies.count)")
            return
        }
        guard
            let resultDependencyA = operation.dependencies[0] as? IdentifiableOperation,
            let resultDependencyB = operation.dependencies[1] as? IdentifiableOperation,
            let resultDependencyC = operation.dependencies[2] as? IdentifiableOperation
        else {
            XCTFail("dependencies must be of type \(IdentifiableOperation.self)")
            return
        }
        XCTAssertEqual(resultDependencyA.id, dependencyA.id)
        XCTAssertEqual(resultDependencyB.id, dependencyB.id)
        XCTAssertEqual(resultDependencyC.id, dependencyC.id)
    }
}

extension Operation_AddDependenciesTests {
    private func makeOperation() -> Operation {
        let operation = Operation()
        weakOperation = operation
        return operation
    }

    private func assertOperationNotLeaking() {
        XCTAssertNil(weakOperation)
    }
}

private final class IdentifiableOperation: Operation {
    private(set) var id: String
    init(id: String) { self.id = id }
}
