import HttpClientLib

extension HttpClientError: Equatable {
    public static func == (lhs: HttpClientError, rhs: HttpClientError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.invalidPath, .invalidPath):
            return true
        case let (.httpStatus(lCode), .httpStatus(rCode)):
            return lCode == rCode
        default:
            return false
        }
    }
}
