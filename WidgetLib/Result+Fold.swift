import Foundation

extension Result {
    public func fold<R>(
        success: @escaping (Success) -> R,
        failure: @escaping (Failure) -> R
    ) -> R {
        switch self {
        case let .success(value):
            return success(value)
        case let .failure(error):
            return failure(error)
        }
    }
}
