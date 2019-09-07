import XCTest
@testable import TfLBusWidgetFeature

final class ViewModelOperationQueueTests: XCTestCase {

    private typealias `Self` = ViewModelOperationQueueTests
    private enum FakeError: Error { case fake }

    private weak var weakViewModel: ViewModelOperationQueue!
    private weak var weakUserConfigurationMock: MockUserConfiguration!
    private weak var weakTfLWrapperMock: MockTfLWrapper!
    private weak var weakArrivalsFormatterMock: MockArrivalsFormatter!

    override func tearDown() {
        assertViewModelNotLeaking()
        assertUserConfigurationMockNotLeaking()
        assertTfLWrapperMockNotLeaking()
        assertArrivalsFormatterMockNotLeaking()
    }
}

extension ViewModelOperationQueueTests {
    func test_getDisplayModel_withoutStopIdNorLineId_fails() {
        let (userConfigurationMock, _, _, viewModel) = makeViewModel(processingQueue: Self.makeConcurrentQueue())
        userConfigurationMock.stopId = nil
        userConfigurationMock.lineId = nil

        let startRunOnMainThread = XCTestExpectation(description: "start must run on main thred")
        let failureRunOnMainThread = XCTestExpectation(description: "failure must run on main thred")

        viewModel.getDisplayModel(
            start: { if Thread.isMainThread { startRunOnMainThread.fulfill() } },
            success: { _ in },
            failure: { _ in if Thread.isMainThread { failureRunOnMainThread.fulfill() } }
        )

        wait(for: [startRunOnMainThread, failureRunOnMainThread], timeout: 0.1)
    }

    func test_getDisplayModel_withoutStopId_fails() {
        let (userConfigurationMock, _, _, viewModel) = makeViewModel(processingQueue: Self.makeConcurrentQueue())
        userConfigurationMock.stopId = nil
        userConfigurationMock.lineId = "lineId"

        let startRunOnMainThread = XCTestExpectation(description: "start must run on main thred")
        let failureRunOnMainThread = XCTestExpectation(description: "failure must run on main thred")

        viewModel.getDisplayModel(
            start: { if Thread.isMainThread { startRunOnMainThread.fulfill() } },
            success: { _ in },
            failure: { _ in if Thread.isMainThread { failureRunOnMainThread.fulfill() } }
        )

        wait(for: [startRunOnMainThread, failureRunOnMainThread], timeout: 0.1)
    }

    func test_getDisplayModel_withoutLineId_fails() {
        let (userConfigurationMock, _, _, viewModel) = makeViewModel(processingQueue: Self.makeConcurrentQueue())
        userConfigurationMock.stopId = "stopId"
        userConfigurationMock.lineId = nil

        let startRunOnMainThread = XCTestExpectation(description: "start must run on main thred")
        let failureRunOnMainThread = XCTestExpectation(description: "failure must run on main thred")

        viewModel.getDisplayModel(
            start: { if Thread.isMainThread { startRunOnMainThread.fulfill() } },
            success: { _ in },
            failure: { _ in if Thread.isMainThread { failureRunOnMainThread.fulfill() } }
        )

        wait(for: [startRunOnMainThread, failureRunOnMainThread], timeout: 0.1)
    }

    func test_getDisplayModel_whenBusStopFetchingFails_fails() {
        let (userConfigurationMock, tflWrapperMock, arrivalsFormatterMock, viewModel)
            = makeViewModel(processingQueue: Self.makeConcurrentQueue())
        userConfigurationMock.stopId = "stopId"
        userConfigurationMock.lineId = "lineId"
        tflWrapperMock.busStopFromIdWithCompletion = { _, completion in
            completion(.failure(.generic(FakeError.fake)))
        }
        tflWrapperMock.arrivalsInSecondsFromStopIdLineIdWithCompletion = { _, _, completion in
            completion(.success([]))
        }
        arrivalsFormatterMock.arrivalsResult = "formattedArrivals"

        let startRunOnMainThread = XCTestExpectation(description: "start must run on main thred")
        let failureRunOnMainThread = XCTestExpectation(description: "failure must run on main thred")

        viewModel.getDisplayModel(
            start: { if Thread.isMainThread { startRunOnMainThread.fulfill() } },
            success: { _ in },
            failure: { _ in if Thread.isMainThread { failureRunOnMainThread.fulfill() } }
        )

        wait(for: [startRunOnMainThread, failureRunOnMainThread], timeout: 0.1)
    }

    func test_getDisplayModel_whenArrivalsFetchingFails_fails() {
        let (userConfigurationMock, tflWrapperMock, arrivalsFormatterMock, viewModel)
            = makeViewModel(processingQueue: Self.makeConcurrentQueue())
        userConfigurationMock.stopId = "stopId"
        userConfigurationMock.lineId = "lineId"
        tflWrapperMock.busStopFromIdWithCompletion = { _, completion in
            completion(.success(.init(id: "stopId", streetCode: "streetCode", stopName: "STOP NAME")))
        }
        tflWrapperMock.arrivalsInSecondsFromStopIdLineIdWithCompletion = { _, _, completion in
            completion(.failure(.generic(FakeError.fake)))
        }
        arrivalsFormatterMock.arrivalsResult = "formattedArrivals"

        let startRunOnMainThread = XCTestExpectation(description: "start must run on main thred")
        let failureRunOnMainThread = XCTestExpectation(description: "failure must run on main thred")

        viewModel.getDisplayModel(
            start: { if Thread.isMainThread { startRunOnMainThread.fulfill() } },
            success: { _ in },
            failure: { _ in if Thread.isMainThread { failureRunOnMainThread.fulfill() } }
        )

        wait(for: [startRunOnMainThread, failureRunOnMainThread], timeout: 0.1)
    }

    func test_getDisplayModel_whenFetchingSucceeds_succeeds() {
        let (userConfigurationMock, tflWrapperMock, arrivalsFormatterMock, viewModel)
            = makeViewModel(processingQueue: Self.makeConcurrentQueue())
        userConfigurationMock.stopId = "stopId"
        userConfigurationMock.lineId = "lineId"
        tflWrapperMock.busStopFromIdWithCompletion = { _, completion in
            completion(.success(.init(id: "stopId", streetCode: "streetCode", stopName: "STOP NAME")))
        }
        tflWrapperMock.arrivalsInSecondsFromStopIdLineIdWithCompletion = { _, _, completion in
            completion(.success([]))
        }
        arrivalsFormatterMock.arrivalsResult = "formattedArrivals"

        let startRunOnMainThread = XCTestExpectation(description: "start must run on main thred")
        let successRunOnMainThread = XCTestExpectation(description: "success must run on main thred")
        let busStopCodeExpectation = XCTestExpectation(description: "bus-stop code must be 'streetCode'")
        let busStopNameExpectation = XCTestExpectation(description: "bus-stop name must be 'STOP NAME'")
        let lineExpectation = XCTestExpectation(description: "line must be 'LINEID'")
        let arrivalsExpectation = XCTestExpectation(description: "arrivals must be 'formattedArrivals'")

        viewModel.getDisplayModel(
            start: { if Thread.isMainThread { startRunOnMainThread.fulfill() } },
            success: { displayModel in
                if Thread.isMainThread { successRunOnMainThread.fulfill() }
                if displayModel.busStopCode == "streetCode" { busStopCodeExpectation.fulfill() }
                if displayModel.busStopName == "STOP NAME" { busStopNameExpectation.fulfill() }
                if displayModel.line == "LINEID" { lineExpectation.fulfill() }
                if displayModel.arrivals == "formattedArrivals" { arrivalsExpectation.fulfill() }
            },
            failure: { _ in }
        )

        wait(
            for: [
                startRunOnMainThread, successRunOnMainThread,
                busStopCodeExpectation, busStopNameExpectation, lineExpectation, arrivalsExpectation
            ],
            timeout: 0.1
        )
    }
}

extension ViewModelOperationQueueTests {
    private func assertViewModelNotLeaking() {
        XCTAssertNil(weakViewModel)
    }

    private func assertUserConfigurationMockNotLeaking() {
        XCTAssertNil(weakUserConfigurationMock)
    }

    private func assertTfLWrapperMockNotLeaking() {
        XCTAssertNil(weakTfLWrapperMock)
    }

    private func assertArrivalsFormatterMockNotLeaking() {
        XCTAssertNil(weakArrivalsFormatterMock)
    }

    private func makeViewModel(
        processingQueue: OperationQueue
    ) -> (MockUserConfiguration, MockTfLWrapper, MockArrivalsFormatter, ViewModelOperationQueue) {
        let userConfigurationMock = MockUserConfiguration()
        let tflWrapperMock = MockTfLWrapper()
        let arrivalsFormatterMock = MockArrivalsFormatter()
        let viewModel = ViewModelOperationQueue(
            userConfiguration: userConfigurationMock,
            tflWrapper: tflWrapperMock,
            arrivalsFormatter: arrivalsFormatterMock,
            processingQueue: processingQueue
        )
        weakViewModel = viewModel
        weakUserConfigurationMock = userConfigurationMock
        weakTfLWrapperMock = tflWrapperMock
        weakArrivalsFormatterMock = arrivalsFormatterMock
        return (userConfigurationMock, tflWrapperMock, arrivalsFormatterMock, viewModel)
    }

    private static func makeConcurrentQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }
}
