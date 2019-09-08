import UIKit
import RepositoryLib

enum MainBuilder {

    static func makeViewController() -> UIViewController {
        let userConfiguration = RepositoryLib.Builder.makeUserConfiguration()
        let viewModel = MainViewModelDefault(userConfiguration: userConfiguration)
        return MainViewController(viewModel: viewModel)
    }
}
