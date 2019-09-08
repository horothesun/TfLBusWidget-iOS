import Foundation
import HttpClientLib

public enum Builder {

    public static func makeTfLWrapper() -> TfLWrapper {
        return TfLWrapperDefault(httpClient: HttpClientLib.Builder.makeHttpClient())
    }

    public static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }
}
