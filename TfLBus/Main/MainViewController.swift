import UIKit
import MainViewModel

final class MainViewController: UIViewController {

    private let viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureLayout()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
    }

    private func configureViewHierarchy() {
        // TODO: implement... 🔥🔥🔥
    }

    private func configureLayout() {
        // TODO: implement... 🔥🔥🔥
    }

    private func configureViews() {
        title = viewModel.title
        view.backgroundColor = .white
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .darkGray
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
    }
}
