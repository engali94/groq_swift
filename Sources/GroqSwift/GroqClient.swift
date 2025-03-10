#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

/// A client for interacting with the Groq API.
///
/// This client provides methods to interact with Groq's language models through their REST API.
/// It supports both regular and streaming completions, with proper error handling and Linux compatibility.
@MainActor
public final class GroqClient: Sendable {
    // swiftlint:disable force_unwrapping
    /// The default host URL for the Groq API.
    public static nonisolated let defaultHost = URL(string: "https://api.groq.com/openai/v1")!
    // swiftlint:enable force_unwrapping

    private let apiKey: String
    private let host: URL
    private let session: URLSession

    /// Initialize a new GroqClient
    /// - Parameters:
    ///   - apiKey: Your Groq API key
    ///   - host: Optional host URL, defaults to the standard Groq API endpoint
    ///   - session: Optional URLSession, defaults to shared URLSession
    public init(
        apiKey: String,
        host: URL = GroqClient.defaultHost,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.host = host
        self.session = session
    }

    private func headers() -> [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }

    private func fetch<T: Decodable>(
        _ method: String,
        _ path: String,
        params: [String: JSONValue]? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(url: host, resolvingAgainstBaseURL: true)
        urlComponents?.path += path

        guard let url = urlComponents?.url else {
            throw GroqError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers()

        if let params = params {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(params)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqError.invalidResponse(String(data: data, encoding: .utf8) ?? "Unknown response")
        }

        guard 200...299 ~= httpResponse.statusCode else {
            if let errorDetail = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw GroqError.from(statusCode: httpResponse.statusCode, message: errorDetail.error.message)
            }
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GroqError.from(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    /// Creates a chat completion for the provided messages.
    ///
    /// - Parameter request: The chat completion request containing the messages and model configuration
    /// - Returns: A response containing the generated completion
    /// - Throws: `GroqError` if the request fails or the response is invalid
    public func createChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        try await fetch("POST", "/chat/completions", params: request.dictionary)
    }

    // swiftlint:disable function_body_length
    /// Creates a streaming chat completion that yields responses as they become available.
    ///
    /// - Parameter request: The chat completion request containing the messages and model configuration
    /// - Returns: An async stream of completion responses
    /// - Note: The stream will automatically end when the completion is finished or if an error occurs
    public func createStreamingChatCompletion(_ request: ChatCompletionRequest) -> AsyncThrowingStream<ChatCompletionChunkResponse, Error> {
        #if canImport(FoundationNetworking)
        // Linux implementation using our custom stream function
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var streamRequest = request
                    streamRequest.stream = true
                    
                    // Create the URL request synchronously
                    var urlComponents = URLComponents(url: host, resolvingAgainstBaseURL: true)
                    urlComponents?.path += "/chat/completions"
                    
                    guard let url = urlComponents?.url else {
                        throw GroqError.invalidURL
                    }
                    
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.allHTTPHeaderFields = headers()
                    urlRequest.httpBody = try JSONEncoder().encode(streamRequest)
                    
                    let decoder = JSONDecoder()
                    
                    let stream = session.stream(
                        request: urlRequest,
                        with: ChatCompletionChunkResponse.self,
                        decoder: decoder,
                        validate: { response in
                            guard let httpResponse = response as? HTTPURLResponse else {
                                throw GroqError.invalidResponse("Stream request failed")
                            }
                            
                            if httpResponse.statusCode != 200 {
                                throw GroqError.from(statusCode: httpResponse.statusCode, message: "Stream request failed")
                            }
                        },
                        extractNextJSON: { buffer in
                            // Look for SSE data: format
                            var startIndex = buffer.startIndex
                            while startIndex < buffer.endIndex {
                                // Look for newlines
                                if let newlineRange = buffer[startIndex...].firstRange(of: Data("\n".utf8)) {
                                    let lineData = buffer[startIndex..<newlineRange.lowerBound]
                                    startIndex = newlineRange.upperBound
                                    
                                    // Check if line starts with "data: "
                                    let dataPrefix = Data("data: ".utf8)
                                    if lineData.count > dataPrefix.count, 
                                       lineData.starts(with: dataPrefix) {
                                        let jsonData = lineData.dropFirst(dataPrefix.count)
                                        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                                        
                                        // Skip empty lines and [DONE] marker
                                        if jsonString.trimmingCharacters(in: .whitespaces).isEmpty ||
                                           jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                                            continue
                                        }
                                        
                                        // Remove the processed data from the buffer
                                        buffer.removeSubrange(buffer.startIndex..<startIndex)
                                        return jsonData
                                    }
                                } else {
                                    break // No more newlines
                                }
                            }
                            return nil
                        }
                    )
                    
                    for try await response in stream {
                        continuation.yield(response)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        #else
        // Standard macOS/iOS implementation
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = request
                    request.stream = true

                    var urlComponents = URLComponents(url: host, resolvingAgainstBaseURL: true)
                    urlComponents?.path += "/chat/completions"

                    guard let url = urlComponents?.url else {
                        throw GroqError.invalidURL
                    }

                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.allHTTPHeaderFields = headers()
                    urlRequest.httpBody = try JSONEncoder().encode(request)

                    let (bytes, response) = try await session.bytes(for: urlRequest)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw GroqError.invalidResponse("Stream request failed")
                    }

                    if httpResponse.statusCode != 200 {
                        if let data = try? await bytes.reduce(into: Data()) { data, byte in
                            data.append(byte)
                        },
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            throw GroqError.from(statusCode: httpResponse.statusCode, message: errorResponse.error.message)
                        }
                        throw GroqError.from(statusCode: httpResponse.statusCode, message: "Stream request failed")
                    }

                    let decoder = JSONDecoder()

                    var currentLine = ""
                    for try await byte in bytes {
                        if byte == UInt8(ascii: "\n") {
                            if currentLine.isEmpty { continue }

                            guard currentLine.hasPrefix("data: ") else {
                                currentLine = ""
                                continue
                            }

                            let jsonString = String(currentLine.dropFirst(6))
                            currentLine = ""

                            if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                                break
                            }

                            if let data = jsonString.data(using: .utf8) {
                                if let response = try? decoder.decode(ChatCompletionChunkResponse.self, from: data) {
                                    continuation.yield(response)
                                }
                            }
                        } else {
                            currentLine.append(Character(UnicodeScalar(byte)))
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        #endif
    }

    // swiftlint:enable function_body_length

    private func createURLRequest(for request: ChatCompletionRequest) async throws -> URLRequest {
        var urlComponents = URLComponents(url: host, resolvingAgainstBaseURL: true)
        urlComponents?.path += "/chat/completions"

        guard let url = urlComponents?.url else {
            throw GroqError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers()
        urlRequest.httpBody = try JSONEncoder().encode(request)

        return urlRequest
    }
}

private struct ErrorResponse: Decodable {
    struct Error: Decodable {
        let message: String
        let type: String?
        let param: String?
        let code: String?
    }

    let error: Error
}
