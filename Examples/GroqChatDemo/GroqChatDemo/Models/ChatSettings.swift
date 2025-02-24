//
//  ChatSettings.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import Foundation
import GroqSwift

struct ChatSettings: RawRepresentable {
    var temperature: Double = 1.0
    var topP: Double = 1.0
    var maxCompletionTokens: Int?
    var n: Int = 1
    var stop: [String] = []
    var presencePenalty: Double = 0.0
    var frequencyPenalty: Double = 0.0
    var seed: Int?
    var responseFormat: ChatCompletionRequest.ResponseFormat?
    var serviceTier: String?
    var user: String?
    var stream: Bool = true
    var streamOptions: ChatCompletionRequest.StreamOptions?

    private struct Storage: Codable {
        var temperature: Double
        var topP: Double
        var maxCompletionTokens: Int?
        var n: Int
        var stop: [String]
        var presencePenalty: Double
        var frequencyPenalty: Double
        var seed: Int?
        var responseFormat: ChatCompletionRequest.ResponseFormat?
        var serviceTier: String?
        var user: String?
        var stream: Bool
        var streamOptions: ChatCompletionRequest.StreamOptions?
    }

    var rawValue: String {
        let storage = Storage(
            temperature: temperature,
            topP: topP,
            maxCompletionTokens: maxCompletionTokens,
            n: n,
            stop: stop,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            seed: seed,
            responseFormat: responseFormat,
            serviceTier: serviceTier,
            user: user,
            stream: stream,
            streamOptions: streamOptions
        )
        guard let data = try? JSONEncoder().encode(storage),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let storage = try? JSONDecoder().decode(Storage.self, from: data) else {
            return nil
        }
        self.temperature = storage.temperature
        self.topP = storage.topP
        self.maxCompletionTokens = storage.maxCompletionTokens
        self.n = storage.n
        self.stop = storage.stop
        self.presencePenalty = storage.presencePenalty
        self.frequencyPenalty = storage.frequencyPenalty
        self.seed = storage.seed
        self.responseFormat = storage.responseFormat
        self.serviceTier = storage.serviceTier
        self.user = storage.user
        self.stream = storage.stream
        self.streamOptions = storage.streamOptions
    }

    init() {
        self.temperature = 1.0
        self.topP = 1.0
        self.n = 1
        self.stop = []
        self.presencePenalty = 0.0
        self.frequencyPenalty = 0.0
        self.stream = true
        self.streamOptions = ChatCompletionRequest.StreamOptions(intermediateResponses: true)
    }

    var asRequest: ChatCompletionRequest {
        ChatCompletionRequest(
            model: "",  // Set later
            messages: [], // Set later
            stream: stream,
            streamOptions: streamOptions,
            maxCompletionTokens: maxCompletionTokens,
            temperature: temperature,
            topP: topP,
            n: n,
            stop: stop.isEmpty ? nil : stop,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            seed: seed,
            responseFormat: responseFormat,
            serviceTier: serviceTier,
            user: user
        )
    }
}
