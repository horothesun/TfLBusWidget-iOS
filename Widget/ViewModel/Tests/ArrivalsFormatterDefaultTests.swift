import XCTest
import WidgetViewModel

final class ArrivalsFormatterDefaultTests: XCTestCase {

    private weak var weakArrivalsFormatter: ArrivalsFormatterDefault!

    override func tearDown() {
        assertArrivalsFormatterNotLeaking()
    }
}

extension ArrivalsFormatterDefaultTests {
    func test_arrivalsText_withNoArrivals_returnsNA() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [])
        XCTAssertEqual(result, "NA")
    }

    func test_arrivalsText_with0MinArrival_returnsDue() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [0])
        XCTAssertEqual(result, "Due")
    }

    func test_arrivalsText_with2MinsArrival_returns2min() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [2])
        XCTAssertEqual(result, "2'")
    }

    func test_arrivalsText_with0Min_1Min_1Min_2Min_Arrivals_returnsDue_1Min_1Min_2Min() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [0, 1, 1, 2])
        XCTAssertEqual(result, "Due, 1', 1', 2'")
    }
}

extension ArrivalsFormatterDefaultTests {
    private func assertArrivalsFormatterNotLeaking() {
        XCTAssertNil(weakArrivalsFormatter)
    }

    private func makeArrivalsFormatter() -> ArrivalsFormatterDefault {
        let arrivalsFormatter = ArrivalsFormatterDefault()
        weakArrivalsFormatter = arrivalsFormatter
        return arrivalsFormatter
    }
}
