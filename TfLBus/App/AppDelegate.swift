import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private lazy var mainNavigationController = UINavigationController(nibName: nil, bundle: nil)
    private lazy var mainCoordinator: MainCoordinator = MainCoordinatorDefault()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return true }

        window.rootViewController = mainNavigationController
        window.makeKeyAndVisible()

        mainCoordinator.start(from: mainNavigationController) { /* do nothing */ }

        return true
    }
}
