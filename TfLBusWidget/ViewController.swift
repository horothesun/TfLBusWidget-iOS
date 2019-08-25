import UIKit
import NotificationCenter

@objc (ViewController)

final class ViewController: UIViewController {

    private lazy var busStopLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    private lazy var lineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()

    private lazy var arrivalsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 36, weight: .light)
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
        [
            busStopLabel,
            lineLabel,
            arrivalsLabel,
            activityIndicator
        ].forEach(view.addSubview)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            busStopLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            busStopLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        NSLayoutConstraint.activate([
            lineLabel.topAnchor.constraint(equalTo: busStopLabel.bottomAnchor, constant: 4),
            lineLabel.leadingAnchor.constraint(equalTo: busStopLabel.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            arrivalsLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            arrivalsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureViews() {
        view.backgroundColor = .clear
    }
}

extension ViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        viewModel.getDisplayModel(
            start: { [busStopLabel, lineLabel, arrivalsLabel, activityIndicator] in
                busStopLabel.isHidden = true
                lineLabel.isHidden = true
                arrivalsLabel.isHidden = true
                activityIndicator.startAnimating()
            },
            completion: { [busStopLabel, lineLabel, arrivalsLabel, activityIndicator] displayModel in
                busStopLabel.text = "\(displayModel.busStopCode) - \(displayModel.busStopName.capitalized)"
                lineLabel.text = displayModel.line // TODO: add last line's stop! 🔥🔥🔥
                arrivalsLabel.text = displayModel.arrivals
                activityIndicator.stopAnimating()
                busStopLabel.isHidden = false
                lineLabel.isHidden = false
                arrivalsLabel.isHidden = false
                completionHandler(.newData)
            }
        )
    }
}
