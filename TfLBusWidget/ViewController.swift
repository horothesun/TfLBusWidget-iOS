import UIKit
import NotificationCenter

@objc (ViewController)

final class ViewController: UIViewController {

    private lazy var arrivalsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        return activityIndicator
    }()

    private let viewModel = Builder.makeViewModel()

    override func loadView() {
        super.loadView()
        view = UIView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureLayout()
        configureViews()
    }

    private func configureViewHierarchy() {
        [activityIndicator, arrivalsLabel].forEach(view.addSubview)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            arrivalsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arrivalsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureViews() {
        view.backgroundColor = .clear
    }
}

extension ViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        viewModel.getDisplayModel(
            start: { [activityIndicator, arrivalsLabel] in
                arrivalsLabel.isHidden = true
                activityIndicator.startAnimating()
            },
            completion: { [activityIndicator, arrivalsLabel] displayModel in
                arrivalsLabel.text =
                    "\(displayModel.busStopCode) - \(displayModel.busStopName.capitalized)"
                    + " - \(displayModel.line)" // TODO: add last line stop! 🔥🔥🔥
                    + "\n\(displayModel.arrivalsText)"
                activityIndicator.stopAnimating()
                arrivalsLabel.isHidden = false
                completionHandler(.newData)
            }
        )
    }
}
