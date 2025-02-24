//
//  ChatMessage.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    var id: UUID
    var content: String
    var isUser: Bool
    var isStreaming: Bool
    
    init(id: UUID = UUID(), content: String, isUser: Bool, isStreaming: Bool = false) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.isStreaming = isStreaming
    }
}
