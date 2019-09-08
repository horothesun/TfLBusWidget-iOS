import Foundation

public enum Builder {
    public static func makeHttpClient() -> HttpClient {
        return HttpClientURLSession(urlSession: URLSession.shared)
    }
}
