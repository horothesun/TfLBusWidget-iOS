import UIKit
import NotificationCenter
import WidgetLib

@objc (ViewController)

final class ViewController: UIViewController {

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        return label
    }()

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
            errorLabel,
            busStopLabel,
            lineLabel,
            arrivalsLabel,
            activityIndicator
        ].forEach(view.addSubview)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
            start: { [weak self] in
                self?.errorLabel.isHidden = true
                self?.busStopLabel.isHidden = true
                self?.lineLabel.isHidden = true
                self?.arrivalsLabel.isHidden = true
                self?.activityIndicator.startAnimating()
            },
            success: { [weak self] displayModel in
                self?.errorLabel.text = nil
                self?.busStopLabel.text = "\(displayModel.busStopCode) - \(displayModel.busStopName.capitalized)"
                self?.lineLabel.text = displayModel.line // TODO: add last line's stop! 🔥🔥🔥
                self?.arrivalsLabel.text = displayModel.arrivals
                self?.activityIndicator.stopAnimating()
                self?.errorLabel.isHidden = true
                self?.busStopLabel.isHidden = false
                self?.lineLabel.isHidden = false
                self?.arrivalsLabel.isHidden = false
                completionHandler(.newData)
            },
            failure: { [weak self] displayModel in
                self?.errorLabel.text = displayModel.message
                self?.busStopLabel.text = nil
                self?.lineLabel.text = nil
                self?.arrivalsLabel.text = nil
                self?.activityIndicator.stopAnimating()
                self?.errorLabel.isHidden = false
                self?.busStopLabel.isHidden = true
                self?.lineLabel.isHidden = true
                self?.arrivalsLabel.isHidden = true
                completionHandler(.newData)
            }
        )
    }
}
