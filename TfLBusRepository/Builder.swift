import Foundation

public enum Builder {

    public static func makeTfLWrapper() -> TfLWrapper {
        let httpClient = HttpClientURLSession(urlSession: URLSession.shared)
        return TfLWrapperDefault(httpClient: httpClient)
    }

    public static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }
}
