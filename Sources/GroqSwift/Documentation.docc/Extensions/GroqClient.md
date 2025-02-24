# ``GroqSwift/GroqClient``

The main client for interacting with Groq's API.

## Overview

`GroqClient` is the primary interface for making requests to Groq's API. It provides methods for both regular and streaming chat completions, with built-in error handling and type safety.

## Topics

### Creating a Client
- ``init(apiKey:host:session:)``

### Making Requests
- ``createChatCompletion(_:)``
- ``createStreamingChatCompletion(_:)``

### Example

```swift
let client = GroqClient(apiKey: "your-api-key")

let request = ChatCompletionRequest(
    model: .mixtral8x7bChat,
    messages: [Message(role: .user, content: "Hello!")],
    temperature: 0.7
)

// Regular completion
let response = try await client.createChatCompletion(request)
print(response.choices.first?.message.content ?? "")

// Streaming completion
for try await response in await client.createStreamingChatCompletion(request) {
    if let content = response.choices.first?.delta.content {
        print(content, terminator: "")
    }
}
```
