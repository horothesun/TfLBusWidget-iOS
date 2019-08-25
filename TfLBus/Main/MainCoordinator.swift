import UIKit

protocol MainCoordinator {
    func start(
        from navigationController: UINavigationController,
        completionHandler: @escaping () -> Void
    )
}

final class MainCoordinatorDefault {

    private lazy var mainViewController: UIViewController = MainBuilder.makeViewController()

    private weak var navigationController: UINavigationController?
    private var completionHandler: (() -> Void)?
}

extension MainCoordinatorDefault: MainCoordinator {

    func start(
        from navigationController: UINavigationController,
        completionHandler: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.completionHandler = completionHandler

        self.navigationController?.viewControllers = [mainViewController]
    }
}
