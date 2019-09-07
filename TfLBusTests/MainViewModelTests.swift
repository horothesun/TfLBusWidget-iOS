import XCTest
@testable import TfL_Bus

final class MainViewModelTests: XCTestCase {

    private weak var weakViewModel: MainViewModelDefault!

    override func tearDown() {
        assertViewModelNotLeaking()
    }
}

extension MainViewModelTests {
    func test_() {
        // TODO: implement!!! 🔥🔥🔥
    }
}

extension MainViewModelTests {
    private func assertViewModelNotLeaking() {
        XCTAssertNil(weakViewModel)
    }
}
