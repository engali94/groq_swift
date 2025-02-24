import Foundation

/// A chat message with a role and content.
public struct Message: Codable {
    /// The role of the message sender (e.g., "system", "user", "assistant")
    public let role: Role
    /// The content of the message
    public let content: String

    /// Creates a new chat message.
    ///
    /// - Parameters:
    ///   - role: The role of the message sender
    ///   - content: The content of the message
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

/// Available roles for chat messages
public enum Role: String, Codable {
    case system
    case user
    case assistant
}

/// A request to create a chat completion.
public struct ChatCompletionRequest: Codable {
    /// The ID of the model to use for completion
    public let model: String
    /// The messages to generate the completion for
    public let messages: [Message]
    /// Whether to stream the response
    public var stream: Bool?
    /// Options for streaming response. Only set this when stream is true.
    public var streamOptions: StreamOptions?
    /// Maximum number of tokens to generate
    public let maxCompletionTokens: Int?
    /// Sampling temperature between 0 and 2
    public let temperature: Double?
    /// Controls the randomness of the generated text
    public let topP: Double?
    /// The number of completions to generate
    public let n: Int?
    /// The sequence of characters that, if encountered, will stop the generation
    public let stop: [String]?
    /// The penalty for the presence of certain words or phrases in the generated text (-2.0 to 2.0)
    public let presencePenalty: Double?
    /// The penalty for the frequency of certain words or phrases in the generated text (-2.0 to 2.0)
    public let frequencyPenalty: Double?
    /// The seed for the random number generator
    public let seed: Int?
    /// The format of the response
    public let responseFormat: ResponseFormat?
    /// The service tier to use (auto or flex)
    public let serviceTier: String?
    /// A unique identifier for the end-user
    public let user: String?
    /// A list of tools the model may call
    public let tools: [Tool]?
    /// Controls which tool is called by the model
    public let toolChoice: ToolChoice?

    public struct StreamOptions: Codable {
        /// Whether to return intermediate responses as they become available
        public let intermediateResponses: Bool

        public init(intermediateResponses: Bool = true) {
            self.intermediateResponses = intermediateResponses
        }

        private enum CodingKeys: String, CodingKey {
            case intermediateResponses = "intermediate_responses"
        }
    }

    /// Creates a new chat completion request.
    ///
    /// - Parameters:
    ///   - model: The ID of the model to use
    ///   - messages: The messages to generate the completion for
    ///   - stream: Whether to stream the response
    ///   - streamOptions: Options for streaming response. Only set this when stream is true.
    ///   - maxCompletionTokens: Maximum number of tokens to generate
    ///   - temperature: Sampling temperature between 0 and 2
    ///   - topP: Controls the randomness of the generated text
    ///   - n: The number of completions to generate
    ///   - stop: The sequence of characters that, if encountered, will stop the generation
    ///   - presencePenalty: The penalty for the presence of certain words or phrases in the generated text
    ///   - frequencyPenalty: The penalty for the frequency of certain words or phrases in the generated text
    ///   - seed: The seed for the random number generator
    ///   - responseFormat: The format of the response
    ///   - serviceTier: The service tier to use (auto or flex)
    ///   - user: A unique identifier for the end-user
    ///   - tools: A list of tools the model may call
    ///   - toolChoice: Controls which tool is called by the model
    public init(
        model: String,
        messages: [Message],
        stream: Bool? = nil,
        streamOptions: StreamOptions? = nil,
        maxCompletionTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        n: Int? = nil,
        stop: [String]? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        seed: Int? = nil,
        responseFormat: ResponseFormat? = nil,
        serviceTier: String? = nil,
        user: String? = nil,
        tools: [Tool]? = nil,
        toolChoice: ToolChoice? = nil
    ) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.streamOptions = streamOptions
        self.maxCompletionTokens = maxCompletionTokens
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.stop = stop
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.seed = seed
        self.responseFormat = responseFormat
        self.serviceTier = serviceTier
        self.user = user
        self.tools = tools
        self.toolChoice = toolChoice
    }

    public struct ResponseFormat: Codable {
        public let type: String

        public init(type: String) {
            self.type = type
        }
    }

    public struct Tool: Codable {
        public let type: String
        public let function: Function

        public init(type: String, function: Function) {
            self.type = type
            self.function = function
        }

        public struct Function: Codable {
            public let name: String
            public let description: String?
            public let parameters: [String: JSONValue]

            public init(name: String, description: String? = nil, parameters: [String: JSONValue]) {
                self.name = name
                self.description = description
                self.parameters = parameters
            }
        }
    }

    public enum ToolChoice: Codable {
        case none
        case auto
        case required
        case function(name: String)

        private enum CodingKeys: String, CodingKey {
            case type
            case function
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .none:
                try container.encode("none", forKey: .type)
            case .auto:
                try container.encode("auto", forKey: .type)
            case .required:
                try container.encode("required", forKey: .type)
            case .function(let name):
                try container.encode("function", forKey: .type)
                var functionContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .function)
                try functionContainer.encode(name, forKey: .type)
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "none":
                self = .none
            case "auto":
                self = .auto
            case "required":
                self = .required
            case "function":
                let functionContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .function)
                let name = try functionContainer.decode(String.self, forKey: .type)
                self = .function(name: name)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid tool choice type")
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case model
        case messages
        case stream
        case streamOptions = "stream_options"
        case maxCompletionTokens = "max_completion_tokens"
        case temperature
        case topP = "top_p"
        case n
        case stop
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case seed
        case responseFormat = "response_format"
        case serviceTier = "service_tier"
        case user
        case tools
        case toolChoice = "tool_choice"
    }

    var dictionary: [String: JSONValue] {
        var dict: [String: JSONValue] = [
            "model": .string(model),
            "messages": .array(messages.map { message in
                .object([
                    "role": .string(message.role.rawValue),
                    "content": .string(message.content)
                ])
            })
        ]

        if let stream = stream {
            dict["stream"] = .bool(stream)
        }

        if let streamOptions = streamOptions {
            dict["stream_options"] = .object([
                "intermediate_responses": .bool(streamOptions.intermediateResponses)
            ])
        }

        if let maxCompletionTokens = maxCompletionTokens {
            dict["max_completion_tokens"] = .number(Double(maxCompletionTokens))
        }

        if let temperature = temperature {
            dict["temperature"] = .number(temperature)
        }

        if let topP = topP {
            dict["top_p"] = .number(topP)
        }

        if let n = n {
            dict["n"] = .number(Double(n))
        }

        if let stop = stop {
            dict["stop"] = .array(stop.map { .string($0) })
        }

        if let presencePenalty = presencePenalty {
            dict["presence_penalty"] = .number(presencePenalty)
        }

        if let frequencyPenalty = frequencyPenalty {
            dict["frequency_penalty"] = .number(frequencyPenalty)
        }

        if let seed = seed {
            dict["seed"] = .number(Double(seed))
        }

        if let responseFormat = responseFormat {
            dict["response_format"] = .object(["type": .string(responseFormat.type)])
        }

        if let serviceTier = serviceTier {
            dict["service_tier"] = .string(serviceTier)
        }

        if let user = user {
            dict["user"] = .string(user)
        }

        if let tools = tools {
            dict["tools"] = .array(tools.map { tool in
                .object([
                    "type": .string(tool.type),
                    "function": .object([
                        "name": .string(tool.function.name),
                        "description": tool.function.description.map { .string($0) } ?? .null,
                        "parameters": .object(tool.function.parameters)
                    ])
                ])
            })
        }

        if let toolChoice = toolChoice {
            switch toolChoice {
            case .none:
                dict["tool_choice"] = .object(["type": .string("none")])
            case .auto:
                dict["tool_choice"] = .object(["type": .string("auto")])
            case .required:
                dict["tool_choice"] = .object(["type": .string("required")])
            case .function(let name):
                dict["tool_choice"] = .object([
                    "type": .string("function"),
                    "function": .object(["type": .string(name)])
                ])
            }
        }

        return dict
    }
}

/// A response from a chat completion request.
public struct ChatCompletionResponse: Codable {
    /// Unique identifier for this completion
    public let id: String
    /// The object type (always "chat.completion")
    public let object: String
    /// The Unix timestamp of when the completion was created
    public let created: Int
    /// The ID of the model used
    public let model: String
    /// The list of generated completions
    public let choices: [Choice]
    /// Usage statistics for the completion
    public let usage: Usage?
    /// A unique identifier for the system that generated the completion
    public let systemFingerprint: String?
    /// Additional information from Groq
    public let xGroq: XGroq?

    /// A choice generated by the model.
    public struct Choice: Codable {
        /// The index of this choice
        public let index: Int
        /// The message generated by the model
        public let message: Message
        /// The reason why the model stopped generating
        public let finishReason: String?
        /// Log probabilities for the generated tokens
        public let logprobs: LogProbs?

        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
            case logprobs
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
        case systemFingerprint = "system_fingerprint"
        case xGroq = "x_groq"
    }
}

/// A streaming response from a chat completion request.
public struct ChatCompletionChunkResponse: Codable {
    /// Unique identifier for this completion
    public let id: String
    /// The object type (always "chat.completion.chunk")
    public let object: String
    /// The Unix timestamp of when the completion was created
    public let created: Int
    /// The ID of the model used
    public let model: String
    /// The list of generated completions
    public let choices: [Choice]
    /// A unique identifier for the system that generated the completion
    public let systemFingerprint: String?
    /// Additional information from Groq
    public let xGroq: XGroq?

    /// A choice in a streaming response.
    public struct Choice: Codable {
        /// The index of this choice
        public let index: Int
        /// The delta containing the new content
        public let delta: Delta
        /// The reason why the model stopped generating
        public let finishReason: String?
        /// Log probabilities for the generated tokens
        public let logprobs: LogProbs?

        enum CodingKeys: String, CodingKey {
            case index
            case delta
            case finishReason = "finish_reason"
            case logprobs
        }
    }

    /// The delta containing the new content.
    public struct Delta: Codable {
        public let role: Role?
        public let content: String?
    }

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case systemFingerprint = "system_fingerprint"
        case xGroq = "x_groq"
    }
}

/// Additional information from Groq
public struct XGroq: Codable {
    /// Unique identifier for the request
    public let id: String
}

/// Log probabilities for generated tokens
public struct LogProbs: Codable {
    /// Content of the log probabilities
    public let content: [String: Double]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            content = nil
        } else {
            content = try? container.decode([String: Double].self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(content)
    }
}

/// Token usage statistics for a completion.
public struct Usage: Codable {
    /// Number of tokens in the prompt
    public let promptTokens: Int
    /// Number of tokens in the completion
    public let completionTokens: Int
    /// Total number of tokens used
    public let totalTokens: Int
    /// The time the request spent in the queue
    public let queueTime: Double?
    /// The time the request spent processing the prompt
    public let promptTime: Double?
    /// The time the request spent generating the completion
    public let completionTime: Double?
    /// The total time the request took
    public let totalTime: Double?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case queueTime = "queue_time"
        case promptTime = "prompt_time"
        case completionTime = "completion_time"
        case totalTime = "total_time"
    }
}

public enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .number(let number):
            try container.encode(number)
        case .bool(let bool):
            try container.encode(bool)
        case .null:
            try container.encodeNil()
        case .array(let array):
            try container.encode(array)
        case .object(let object):
            try container.encode(object)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
            return
        }

        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid JSON value"
            )
        }
    }
}
