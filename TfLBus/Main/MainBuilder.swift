import UIKit
import MainFeature
import HttpClientLib
import RepositoryLib

enum MainBuilder {
    static func makeViewController() -> UIViewController {
        let viewModel = MainViewModelDefault(
            userConfiguration: makeUserConfiguration(),
            tflWrapper: makeTfLWrapper()
        )
        return MainViewController(viewModel: viewModel)
    }

    private static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }

    private static func makeTfLWrapper() -> TfLWrapper {
        let httpClient = HttpClientURLSession(urlSession: URLSession.shared)
        return TfLWrapperDefault(httpClient: httpClient)
    }
}
