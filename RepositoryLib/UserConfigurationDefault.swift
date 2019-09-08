import Foundation

final class UserConfigurationDefault {

    private let stopIdKey = "stopIdKey"
    private let lineIdKey = "lineIdKey"

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserConfigurationDefault: UserConfiguration {

    var stopId: String? {
        get { return userDefaults.string(forKey: stopIdKey) }
        set { userDefaults.set(newValue, forKey: stopIdKey) }
    }

    var lineId: String? {
        get { return userDefaults.string(forKey: lineIdKey) }
        set { userDefaults.set(newValue, forKey: lineIdKey) }
    }
}
