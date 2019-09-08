import Foundation
import RepositoryLib

final class MockUserDefaults: UserDefaults {

    var stringForKeyResult: String?
    private(set) var setAnyForKeyLastArguments: (value: Any?, defaultName: String)?

    convenience init() {
        self.init(suiteName: "MockUserDefaults")!
    }

    override init?(suiteName suitename: String?) {
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }

    override func string(forKey defaultName: String) -> String? {
        return stringForKeyResult
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        setAnyForKeyLastArguments = (value, defaultName)
    }
}
