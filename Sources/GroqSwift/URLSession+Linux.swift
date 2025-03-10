#if canImport(FoundationNetworking)
import Foundation
import FoundationNetworking

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data, let response = response else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
    
    func bytes(for request: URLRequest) async throws -> (Data, URLResponse) {
        // On Linux, we'll just reuse the data implementation
        // But we should implement a bytes streaming implementation
        return try await data(for: request)
    }
}
#endif 