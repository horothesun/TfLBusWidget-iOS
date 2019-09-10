import UIKit
import MainViewModel
import MainUseCases
import RepositoryLib

enum MainBuilder {

    static func makeViewController() -> UIViewController {
        let viewModel = MainViewModelDefault(
            stopAndLineIdsSetterUseCase: makeStopAndLineIdsSetterUseCase()
        )
        return MainViewController(viewModel: viewModel)
    }

    private static func makeStopAndLineIdsSetterUseCase() -> StopAndLineIdsSetterUseCase {
        return StopAndLineIdsSetterUseCaseDefault(userConfiguration: makeUserConfiguration())
    }

    private static func makeUserConfiguration() -> UserConfiguration {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.horothesun.TfLBus")!
        return UserConfigurationDefault(userDefaults: sharedUserDefaults)
    }
}
