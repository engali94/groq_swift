# GroqSwift

A Swift SDK for the Groq API, providing a convenient way to interact with Groq's language models in Swift applications. The SDK is designed to work on both Apple platforms and Linux.

## Demo App

Here's a demo chat application built using GroqSwift:

<img src="1.png" width="250" alt="Demo Image 1"> <img src="2.png" width="250" alt="Demo Image 2"> <img src="3.png" width="250" alt="Demo Image 3">

## Features

- ✨ Modern async/await API design
- 🔄 Support for both regular and streaming completions
- 🛡️ Type-safe request and response models
- 🐧 Linux compatibility
- ⚡️ Proper error handling with detailed messages
- 📱 Support for all Apple platforms

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/engali94/groq-swift.git", from: "0.1.0")
]
```

## Quick Start

```swift
import GroqSwift

// Initialize the client
let client = GroqClient(apiKey: "your-api-key")

// Create a chat completion request
let request = ChatCompletionRequest(
    model: .mixtral8x7bChat, 
    messages: [Message(role: .user, content: "What is the capital of France?")],
    temperature: 0.7
)

// Regular completion
do {
    let response = try await client.createChatCompletion(request)
    print(response.choices.first?.message.content ?? "")
} catch {
    print("Error: \(error)")
}

// Streaming completion
for try await response in await client.createStreamingChatCompletion(request) {
    if let content = response.choices.first?.delta.content {
        print(content, terminator: "")
    }
}
```

## Advanced Usage

### Message Roles

The SDK supports all message roles:

```swift
// System message to set behavior
let systemMessage = Message(role: .system, content: "You are a helpful assistant")

// User message
let userMessage = Message(role: .user, content: "Hello!")

// Assistant message
let assistantMessage = Message(role: .assistant, content: "Hi there!")
```

### Available Models

Use dot syntax to specify models:

```swift
// LLaMA models
let llamaRequest = ChatCompletionRequest(model: .llama70bChat)
let llamaVersatileRequest = ChatCompletionRequest(model: .llama70bVersatile)

// Mixtral models
let mixtralRequest = ChatCompletionRequest(model: .mixtral8x7bChat)
let mixtralVersatileRequest = ChatCompletionRequest(model: .mixtral8x7bVersatile)

// Gemma models
let gemmaRequest = ChatCompletionRequest(model: .gemma7bChat)
let gemmaVersatileRequest = ChatCompletionRequest(model: .gemma7bVersatile)

// DeepSeek models
let deepseekLlamaRequest = ChatCompletionRequest(model: .deepseekR1DistillLlama70b)
let deepseekQwenRequest = ChatCompletionRequest(model: .deepseekR1DistillQwen32b)
```

### Request Parameters

Customize your requests with various parameters:

```swift
let request = ChatCompletionRequest(
    model: .mixtral8x7bChat,
    messages: messages,
    stream: true,                    // Enable streaming
    maxCompletionTokens: 100,        // Limit response length
    temperature: 0.7,                // Control randomness
    topP: 0.9,                      // Nucleus sampling
    presencePenalty: 0.5,           // Penalize token presence
    frequencyPenalty: 0.5,          // Penalize token frequency
    stop: ["END"],                  // Stop sequences
    user: "user-123"                // User identifier
)
```

### Error Handling

The SDK provides detailed error information:

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

## Demo Application

Check out the [GroqChatDemo](Examples/GroqChatDemo) directory for a complete SwiftUI chat application that demonstrates the SDK's capabilities.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Requirements

- macOS 13.0+
- iOS 16.0+
- watchOS 9.0+
- tvOS 16.0+
- visionOS 1.0+
- Swift 5.9+
