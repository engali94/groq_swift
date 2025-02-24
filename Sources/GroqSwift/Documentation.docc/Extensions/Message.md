# ``GroqSwift/Message``

A chat message with a role and content.

## Overview

`Message` represents a single message in a chat conversation. Each message has a role (system, user, or assistant) and content.

## Topics

### Creating Messages
- ``init(role:content:)``

### Properties
- ``role``
- ``content``

### Example

```swift
// System message to set behavior
let systemMessage = Message(role: .system, content: "You are a helpful assistant")

// User message
let userMessage = Message(role: .user, content: "Hello!")

// Assistant message
let assistantMessage = Message(role: .assistant, content: "Hi there!")
```
