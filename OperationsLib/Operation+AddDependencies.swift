import Foundation

extension Operation {
    public func addDependencies(_ dependencies: Operation...) {
        dependencies.forEach(addDependency(_:))
    }
}
