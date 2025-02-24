import Foundation

/// Represents errors that can occur when using the Groq API
public enum GroqError: LocalizedError {
    /// Authentication failed (e.g., invalid API key)
    case authenticationFailed(String)

    /// Rate limit exceeded
    case rateLimitExceeded(String)

    /// Invalid request parameters
    case invalidRequest(String)

    /// Model is currently overloaded with requests
    case modelOverloaded(String)

    /// The requested model does not exist or is not available
    case modelNotFound(String)

    /// Context length exceeded for the model
    case contextLengthExceeded(String)

    /// Maximum tokens exceeded
    case maxTokensExceeded(String)

    /// Invalid response format from the API
    case invalidResponse(String)

    /// Network related errors
    case networkError(String)

    /// Server returned an error
    case serverError(Int, String)

    /// Unexpected error occurred
    case unexpected(String)

    /// Invalid URL
    case invalidURL

    public var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .rateLimitExceeded(let message):
            return "Rate limit exceeded: \(message)"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .modelOverloaded(let message):
            return "Model is overloaded: \(message)"
        case .modelNotFound(let message):
            return "Model not found: \(message)"
        case .contextLengthExceeded(let message):
            return "Context length exceeded: \(message)"
        case .maxTokensExceeded(let message):
            return "Maximum tokens exceeded: \(message)"
        case .invalidResponse(let message):
            return "Invalid API response: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .unexpected(let message):
            return "Unexpected error: \(message)"
        case .invalidURL:
            return "Invalid URL"
        }
    }

    /// Helper method to convert HTTP status codes to appropriate GroqError types
    static func from(statusCode: Int, message: String) -> GroqError {
        switch statusCode {
        case 401:
            return .authenticationFailed(message)
        case 429:
            return .rateLimitExceeded(message)
        case 400:
            if message.contains("context length") {
                return .contextLengthExceeded(message)
            } else if message.contains("maximum tokens") {
                return .maxTokensExceeded(message)
            } else {
                return .invalidRequest(message)
            }
        case 404:
            return .modelNotFound(message)
        case 500...599:
            return .serverError(statusCode, message)
        default:
            return .unexpected("Unexpected status code: \(statusCode). \(message)")
        }
    }
}

/// Represents errors that can occur during streaming operations
public enum StreamError: LocalizedError {
    /// Stream was cancelled by the client
    case cancelled

    /// Stream connection was lost
    case connectionLost(String)

    /// Invalid data received in stream
    case invalidData(String)

    /// Stream ended unexpectedly
    case unexpectedEnd(String)

    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Stream was cancelled"
        case .connectionLost(let message):
            return "Stream connection lost: \(message)"
        case .invalidData(let message):
            return "Invalid stream data: \(message)"
        case .unexpectedEnd(let message):
            return "Stream ended unexpectedly: \(message)"
        }
    }
}

/// Represents validation errors for request parameters
public enum ValidationError: LocalizedError {
    /// Temperature value is outside valid range (0...2)
    case invalidTemperature(Double)

    /// Top P value is outside valid range (0...1)
    case invalidTopP(Double)

    /// Presence penalty is outside valid range (-2...2)
    case invalidPresencePenalty(Double)

    /// Frequency penalty is outside valid range (-2...2)
    case invalidFrequencyPenalty(Double)

    /// Too many stop sequences (max 4)
    case tooManyStopSequences(Int)

    /// Invalid model name
    case invalidModel(String)

    public var errorDescription: String? {
        switch self {
        case .invalidTemperature(let value):
            return "Temperature must be between 0 and 2, got \(value)"
        case .invalidTopP(let value):
            return "Top P must be between 0 and 1, got \(value)"
        case .invalidPresencePenalty(let value):
            return "Presence penalty must be between -2 and 2, got \(value)"
        case .invalidFrequencyPenalty(let value):
            return "Frequency penalty must be between -2 and 2, got \(value)"
        case .tooManyStopSequences(let count):
            return "Maximum 4 stop sequences allowed, got \(count)"
        case .invalidModel(let model):
            return "Invalid model name: \(model)"
        }
    }
}
