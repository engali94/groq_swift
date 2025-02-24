//
//  ChatViewModel.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import GroqSwift
import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let client: GroqClient
    private var streamTask: Task<Void, Never>?
    
    init() {
        self.client = GroqClient(apiKey: APIKey.groqApiKey)
    }
    
    func cancelStreaming() {
        streamTask?.cancel()
        streamTask = nil
        isLoading = false
    }
    
    func sendMessage(_ text: String, model: GroqModel, settings: ChatSettings) async {
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        streamTask?.cancel()
        
        isLoading = true
        
        let assistantMessage = ChatMessage(content: "", isUser: false, isStreaming: true)
        messages.append(assistantMessage)
        
        streamTask = Task {
            do {
                var accumulatedContent = ""
                
                let stream = client.createStreamingChatCompletion(
                    settings.asRequest.with(
                        model: model.rawValue,
                        messages: messages.dropLast().map { Message(role: $0.isUser ? .user : .assistant, content: $0.content) }
                    )
                )
                
                for try await chunk in stream {
                    if Task.isCancelled { break }
                    
                    if let content = chunk.choices.first?.delta.content {
                        accumulatedContent += content
                        
                        if let lastIndex = messages.indices.last {
                            messages[lastIndex] = ChatMessage(
                                id: assistantMessage.id,
                                content: accumulatedContent,
                                isUser: false,
                                isStreaming: true
                            )
                        }
                    }
                }
                
                if !Task.isCancelled, let lastIndex = messages.indices.last {
                    messages[lastIndex] = ChatMessage(
                        id: assistantMessage.id,
                        content: accumulatedContent,
                        isUser: false,
                        isStreaming: false
                    )
                }
            } catch {
                if !Task.isCancelled {
                    showError = true
                    errorMessage = error.localizedDescription
                    messages.removeLast()
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
}
