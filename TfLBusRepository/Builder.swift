import Foundation

public enum Builder {

    public static func makeTfLWrapper() -> TfLWrapper {
        return TfLWrapperDefault(httpClient: HttpClientURLSession())
    }

    public static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }
}
