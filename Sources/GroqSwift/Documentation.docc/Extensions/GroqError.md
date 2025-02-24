# ``GroqSwift/GroqError``

Errors that can occur when using the GroqSwift SDK.

## Overview

`GroqError` provides detailed error information for various failure scenarios when interacting with Groq's API.

## Topics

### Error Cases
- ``invalidRequest(_:)``
- ``authenticationError(_:)``
- ``apiError(_:_:)``
- ``invalidResponse(_:)``
- ``invalidURL``

### Example

```swift
do {
    let response = try await client.createChatCompletion(request)
} catch let error as GroqError {
    switch error {
    case .invalidRequest(let message):
        print("Invalid request: \(message)")
    case .authenticationError(let message):
        print("Auth error: \(message)")
    case .apiError(let statusCode, let message):
        print("API error \(statusCode): \(message)")
    case .invalidResponse(let message):
        print("Invalid response: \(message)")
    case .invalidURL:
        print("Invalid URL")
    }
} catch {
    print("Unexpected error: \(error)")
}
```
