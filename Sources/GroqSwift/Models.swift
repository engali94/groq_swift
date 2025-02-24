import Foundation

/// Model ID constants for Groq models
public extension String {
    // MARK: - LLaMA Models

    /// LLaMA 3.3 70B model optimized for versatile tasks
    static let llama70bVersatile = "llama-3.3-70b-versatile"

    /// LLaMA 3.3 70B model optimized for chat
    static let llama70bChat = "llama-3.3-70b-chat"

    // MARK: - Mixtral Models

    /// Mixtral 8x7B model optimized for versatile tasks
    static let mixtral8x7bVersatile = "mixtral-8x7b-versatile"

    /// Mixtral 8x7B model optimized for chat
    static let mixtral8x7bChat = "mixtral-8x7b-chat"

    // MARK: - Gemma Models

    /// Gemma 7B model optimized for versatile tasks
    static let gemma7bVersatile = "gemma-7b-versatile"

    /// Gemma 7B model optimized for chat
    static let gemma7bChat = "gemma-7b-chat"

    // MARK: - DeepSeek Models

    /// DeepSeek R1 Distill LLaMA 70B model
    static let deepseekR1DistillLlama70b = "deepseek-r1-distill-llama-70b"

    /// DeepSeek R1 Distill Qwen 32B model
    static let deepseekR1DistillQwen32b = "deepseek-r1-distill-qwen-32b"
}
