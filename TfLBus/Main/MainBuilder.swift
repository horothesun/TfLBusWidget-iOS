import TfLBusRepository
import UIKit

enum MainBuilder {

    static func makeViewController() -> UIViewController {
        let userConfiguration = TfLBusRepository.Builder.makeUserConfiguration()
        let viewModel = MainViewModelDefault(userConfiguration: userConfiguration)
        return MainViewController(viewModel: viewModel)
    }
}
