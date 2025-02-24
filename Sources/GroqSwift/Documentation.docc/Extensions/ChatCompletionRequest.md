# ``GroqSwift/ChatCompletionRequest``

A request to create a chat completion.

## Overview

`ChatCompletionRequest` encapsulates all the parameters needed to generate a chat completion from Groq's models.

## Topics

### Creating Requests
- ``init(model:messages:stream:streamOptions:maxCompletionTokens:temperature:topP:n:stop:presencePenalty:frequencyPenalty:seed:responseFormat:serviceTier:user:tools:toolChoice:)``

### Properties
- ``model``
- ``messages``
- ``stream``
- ``streamOptions``
- ``maxCompletionTokens``
- ``temperature``
- ``topP``
- ``n``
- ``stop``
- ``presencePenalty``
- ``frequencyPenalty``
- ``seed``
- ``responseFormat``
- ``serviceTier``
- ``user``
- ``tools``
- ``toolChoice``

### Example

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
