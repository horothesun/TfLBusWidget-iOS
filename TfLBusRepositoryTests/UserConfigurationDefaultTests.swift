import XCTest
@testable import TfLBusRepository

final class UserConfigurationDefaultTests: XCTestCase {

    private weak var weakUserConfiguration: UserConfigurationDefault!
    private weak var weakUserDefaults: MockUserDefaults!

    override func tearDown() {
        assertUserConfigurationNotLeaking()
        assertUserDefaultNotLeaking()
    }
}

// MARK:- stopId

extension UserConfigurationDefaultTests {
    func test_stopId_withEmptyUserDefaults_returnsNil() {
        let (userDefaultsMock, userConfiguration) = makeUserConfiguration()
        userDefaultsMock.stringForKeyResult = nil
        XCTAssertNil(userConfiguration.stopId)
    }

    func test_settingStopId_forwardsToUserDefaults() {
        let (userDefaultsMock, userConfiguration) = makeUserConfiguration()
        let stopId = "123"
        userConfiguration.stopId = stopId
        guard
            let (value, _) = userDefaultsMock.setAnyForKeyLastArguments,
            let forwardedStopId = value as? String
        else {
            XCTFail("stopId not forwarded to UserDefaults")
            return
        }
        XCTAssertEqual(forwardedStopId, stopId)
    }
}

// MARK:- lineId

extension UserConfigurationDefaultTests {
    func test_lineId_withEmptyUserDefaults_returnsNil() {
        let (userDefaultsMock, userConfiguration) = makeUserConfiguration()
        userDefaultsMock.stringForKeyResult = nil
        XCTAssertNil(userConfiguration.lineId)
    }

    func test_settingLineId_forwardsToUserDefaults() {
        let (userDefaultsMock, userConfiguration) = makeUserConfiguration()
        let lineId = "123"
        userConfiguration.lineId = lineId
        guard
            let (value, _) = userDefaultsMock.setAnyForKeyLastArguments,
            let forwardedLineId = value as? String
        else {
            XCTFail("lineId not forwarded to UserDefaults")
            return
        }
        XCTAssertEqual(forwardedLineId, lineId)
    }
}

extension UserConfigurationDefaultTests {
    private func assertUserConfigurationNotLeaking() {
        XCTAssertNil(weakUserConfiguration)
    }

    private func assertUserDefaultNotLeaking() {
        XCTAssertNil(weakUserDefaults)
    }

    private func makeUserConfiguration() -> (MockUserDefaults, UserConfigurationDefault) {
        let userDefaultsMock = MockUserDefaults()
        let userConfiguration = UserConfigurationDefault(userDefaults: userDefaultsMock)
        weakUserConfiguration = userConfiguration
        weakUserDefaults = userDefaultsMock
        return (userDefaultsMock, userConfiguration)
    }
}
