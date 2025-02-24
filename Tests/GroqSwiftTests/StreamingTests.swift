import XCTest
@testable import GroqSwift

final class StreamingTests: XCTestCase {
 
    override func setUp() {
        super.setUp()
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
    }
    
    private func createSSEData(_ chunks: [String]) -> Data {
        let sseChunks = chunks.map { chunk -> String in
            let singleLineChunk = chunk.replacingOccurrences(of: "\n", with: "")
            return "data: \(singleLineChunk)\n\n"
        }.joined()
        return sseChunks.data(using: .utf8)!
    }
    
    func testStreamingSingleChunk() async throws {
        let chunks = ["""
        {
            "id": "test-id",
            "object": "chat.completion.chunk",
            "created": 1677649420,
            "model": "mixtral-8x7b-chat",
            "choices": [{
                "index": 0,
                "delta": {
                    "role": "assistant",
                    "content": "Hello"
                },
                "finish_reason": null
            }]
        }
        """]
        
        MockURLProtocol.mockData = createSSEData(chunks + ["[DONE]"])
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.groq.com/openai/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "text/event-stream"]
        )
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = await GroqClient(apiKey: "test-key", session: session)
        
        let request = ChatCompletionRequest(
            model: "mixtral-8x7b-chat",
            messages: [Message(role: .user, content: "Hi")],
            stream: true
        )
        
        var responses: [ChatCompletionChunkResponse] = []
        for try await response in await client.createStreamingChatCompletion(request) {
            responses.append(response)
        }
        
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].choices[0].delta.content, "Hello")
    }
    
    func testStreamingMultipleChunks() async throws {
        let response = """
        data: {"id":"chatcmpl-f51b2cd2-bef7-417e-964e-a08f0b513c22","object":"chat.completion.chunk","created":1730241104,"model":"llama3-8b-8192","choices":[{"index":0,"delta":{"role":"assistant","content":"Fast"},"finish_reason":null,"logprobs":null}],"system_fingerprint":"fp_179b0f92c9","x_groq":{"id":"req_01jbd6g2qdfw2adyrt2az8hz4w"}}\n
        data: {"id":"chatcmpl-f51b2cd2-bef7-417e-964e-a08f0b513c22","object":"chat.completion.chunk","created":1730241104,"model":"llama3-8b-8192","choices":[{"index":0,"delta":{"content":" language"},"finish_reason":null,"logprobs":null}],"system_fingerprint":"fp_179b0f92c9","x_groq":{"id":"req_01jbd6g2qdfw2adyrt2az8hz4w"}}\n
        data: {"id":"chatcmpl-f51b2cd2-bef7-417e-964e-a08f0b513c22","object":"chat.completion.chunk","created":1730241104,"model":"llama3-8b-8192","choices":[{"index":0,"delta":{"content":" models"},"finish_reason":"stop","logprobs":null}],"system_fingerprint":"fp_179b0f92c9","x_groq":{"id":"req_01jbd6g2qdfw2adyrt2az8hz4w"}}\n
        data: [DONE]\n
        """.data(using: .utf8)!
        
        MockURLProtocol.mockData = response
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.groq.com/openai/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "text/event-stream"]
        )
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = await GroqClient(apiKey: "test-key", session: session)
        
        let request = ChatCompletionRequest(
            model: "llama3-8b-8192",
            messages: [Message(role: .user, content: "What are fast language models?")],
            stream: true
        )
        
        var responses: [ChatCompletionChunkResponse] = []
        for try await response in await client.createStreamingChatCompletion(request) {
            responses.append(response)
        }
        
        XCTAssertEqual(responses.count, 3)
        XCTAssertEqual(responses[0].choices[0].delta.role, .assistant)
        XCTAssertEqual(responses[0].choices[0].delta.content, "Fast")
        XCTAssertEqual(responses[1].choices[0].delta.content, " language")
        XCTAssertEqual(responses[2].choices[0].delta.content, " models")
        XCTAssertEqual(responses[2].choices[0].finishReason, "stop")
        XCTAssertEqual(responses[0].systemFingerprint, "fp_179b0f92c9")
        XCTAssertEqual(responses[0].xGroq?.id, "req_01jbd6g2qdfw2adyrt2az8hz4w")
    }
    
    func testStreamingEmptyLines() async throws {
        let response = """
        data: {"id":"test","object":"chat.completion.chunk","created":1677649420,"model":"mixtral-8x7b-chat","choices":[{"index":0,"delta":{"role":"assistant","content":"Hello"},"finish_reason":null}]}
        
        data: [DONE]
        
        """.data(using: .utf8)!
        
        MockURLProtocol.mockData = response
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.groq.com/openai/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "text/event-stream"]
        )
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = await GroqClient(apiKey: "test-key", session: session)
        
        let request = ChatCompletionRequest(
            model: "mixtral-8x7b-chat",
            messages: [Message(role: .user, content: "Hi")],
            stream: true
        )
        
        var responses: [ChatCompletionChunkResponse] = []
        for try await response in await client.createStreamingChatCompletion(request) {
            responses.append(response)
        }
        
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].choices[0].delta.content, "Hello")
    }
    
    func testStreamingNetworkError() async throws {
        struct MockError: Error {}
        
        MockURLProtocol.mockError = MockError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = await GroqClient(apiKey: "test-key", session: session)
        
        let request = ChatCompletionRequest(
            model: "mixtral-8x7b-chat",
            messages: [Message(role: .user, content: "Hi")],
            stream: true
        )
        
        do {
            for try await _ in await client.createStreamingChatCompletion(request) {}
            XCTFail("Expected error but got success")
        } catch let error as NSError {
            XCTAssertTrue(error.domain.contains("MockError"), "Expected MockError but got \(error)")
        }
    }
}
