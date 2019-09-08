import Foundation
import WidgetFeature
import MainFeature

public final class UserConfigurationDefault {

    private let stopIdKey = "stopIdKey"
    private let lineIdKey = "lineIdKey"

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public var stopId: String? {
        get { return userDefaults.string(forKey: stopIdKey) }
        set { userDefaults.set(newValue, forKey: stopIdKey) }
    }

    public var lineId: String? {
        get { return userDefaults.string(forKey: lineIdKey) }
        set { userDefaults.set(newValue, forKey: lineIdKey) }
    }
}

extension UserConfigurationDefault: WidgetFeature.UserConfiguration { }
extension UserConfigurationDefault: MainFeature.UserConfiguration { }
