import XCTest
@testable import TfLBusRepository

final class TfLWrapperDefaultTests: XCTestCase {

    private weak var weakTfLWrapper: TfLWrapperDefault!

    override func tearDown() {
        assertTfLWrapperNotLeaking()
    }
}

extension TfLWrapperDefaultTests {
    func test_() {
        // TODO: implement!!! 🔥🔥🔥
    }
}

extension TfLWrapperDefaultTests {
    private func assertTfLWrapperNotLeaking() {
        XCTAssertNil(weakTfLWrapper)
    }
}
