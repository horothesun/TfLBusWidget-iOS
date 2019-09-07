import XCTest
@testable import TfLBusWidgetFeature

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

    func test_arrivalsText_withLessThan1MinArrival_returnsDue() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [10])
        XCTAssertEqual(result, "Due")
    }

    func test_arrivalsText_with2MinsArrival_returns2min() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [120])
        XCTAssertEqual(result, "2'")
    }

    func test_arrivalsText_with10s_60s_119s_121s_Arrivals_returnsDue_1m_1m_2m() {
        let arrivalsFormatter = makeArrivalsFormatter()
        let result = arrivalsFormatter.arrivalsText(from: [10, 60, 119, 121])
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
