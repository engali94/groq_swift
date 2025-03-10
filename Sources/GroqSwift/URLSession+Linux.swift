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
    
    func stream<T: Decodable>(request: URLRequest, with responseType: T.Type, decoder: JSONDecoder, validate: @escaping (URLResponse) throws -> Void, extractNextJSON: @escaping (inout Data) -> Data?) -> AsyncThrowingStream<T, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let task = self.dataTask(with: request)

                let delegate = StreamingDelegate(
                    urlResponseCallback: { response in
                        do {
                            try validate(response)
                        } catch {
                            continuation.finish(throwing: error)
                        }
                    },
                    dataCallback: { buffer in
                        while let chunk = extractNextJSON(&buffer) {
                            do {
                                let decodedObject = try decoder.decode(T.self, from: chunk)
                                continuation.yield(decodedObject)
                            } catch {
                                continuation.finish(throwing: error)
                                return
                            }
                        }
                    },
                    completionCallback: { error in
                        if let error {
                            continuation.finish(throwing: error)
                        }
                        continuation.finish()
                    }
                )
                task.delegate = delegate

                continuation.onTermination = { terminationState in
                    // Cancellation of our task should cancel the URLSessionDataTask
                    if case .cancelled = terminationState {
                        task.cancel()
                    }
                }

                task.resume()
            }
        }
    }
}

internal final class StreamingDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    let urlResponseCallback: (@Sendable (URLResponse) -> Void)?
    let dataCallback: (@Sendable (inout Data) -> Void)?
    let completionCallback: (@Sendable (Error?) -> Void)?

    var buffer = Data()

    init(urlResponseCallback: (@Sendable (URLResponse) -> Void)?,
         dataCallback: (@Sendable (inout Data) -> Void)?,
         completionCallback: (@Sendable (Error?) -> Void)?
    ) {
        self.urlResponseCallback = urlResponseCallback
        self.dataCallback = dataCallback
        self.completionCallback = completionCallback
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        urlResponseCallback?(response)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        buffer.append(data)

        dataCallback?(&buffer)
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        completionCallback?(error)
    }
}
#endif 