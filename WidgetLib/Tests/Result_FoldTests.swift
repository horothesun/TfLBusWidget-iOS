import XCTest
import WidgetLib

final class Result_FoldTests: XCTestCase {

    private enum FakeError: String, Error { case fake }

    func test_foldSuccess_toString() {
        let result = Result<Int, FakeError>.success(123)
        XCTAssertEqual(
            result.fold(success: { "\($0)" }, failure: { "\($0)" }),
            "123"
        )
    }

    func test_foldFailure_toString() {
        let result = Result<Int, FakeError>.failure(.fake)
        XCTAssertEqual(
            result.fold(success: { "\($0)" }, failure: { "\($0)" }),
            FakeError.fake.rawValue
        )
    }
}
