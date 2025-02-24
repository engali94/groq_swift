import XCTest
@testable import GroqSwift

final class ModelsTests: XCTestCase {
    func testMessageEncoding() throws {
        let message = Message(role: .user, content: "Hello")
        let data = try JSONEncoder().encode(message)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertEqual(json, """
        {"role":"user","content":"Hello"}
        """)
    }
    
    func testMessageDecoding() throws {
        let json = #"{"role":"assistant","content":"Hi there!"}"#
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let message = try decoder.decode(Message.self, from: data)
        
        XCTAssertEqual(message.role, .assistant)
        XCTAssertEqual(message.content, "Hi there!")
    }
    
    func testInvalidMessageRoleDecoding() throws {
        let json = #"{"role":"invalid","content":"Hi"}"#
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(Message.self, from: data)) { error in
            guard case DecodingError.dataCorrupted = error else {
                XCTFail("Expected DecodingError.dataCorrupted but got \(error)")
                return
            }
        }
    }
    
    func testChatCompletionRequestEncoding() throws {
        let request = ChatCompletionRequest(
            model: "mixtral-8x7b-chat",
            messages: [Message(role: .user, content: "Hi")],
            stream: true,
            maxCompletionTokens: 100,
            temperature: 0.7
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        let decoder = JSONDecoder()
        let decodedRequest = try decoder.decode(ChatCompletionRequest.self, from: data)
        
        XCTAssertEqual(decodedRequest.model, "mixtral-8x7b-chat")
        XCTAssertEqual(decodedRequest.messages.count, 1)
        XCTAssertEqual(decodedRequest.messages[0].role, .user)
        XCTAssertEqual(decodedRequest.messages[0].content, "Hi")
        XCTAssertEqual(decodedRequest.stream, true)
        XCTAssertEqual(decodedRequest.maxCompletionTokens, 100)
        XCTAssertEqual(decodedRequest.temperature, 0.7)
    }
    
    func testChatCompletionResponseDecoding() throws {
        let json = """
        {
            "id": "chatcmpl-f51b2cd2-bef7-417e-964e-a08f0b513c22",
            "object": "chat.completion",
            "created": 1730241104,
            "model": "llama3-8b-8192",
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": "This is a test response"
                    },
                    "logprobs": null,
                    "finish_reason": "stop"
                }
            ],
            "usage": {
                "queue_time": 0.037493756,
                "prompt_tokens": 18,
                "prompt_time": 0.000680594,
                "completion_tokens": 556,
                "completion_time": 0.463333333,
                "total_tokens": 574,
                "total_time": 0.464013927
            },
            "system_fingerprint": "fp_179b0f92c9",
            "x_groq": { "id": "req_01jbd6g2qdfw2adyrt2az8hz4w" }
        }
        """
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(ChatCompletionResponse.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(response.id, "chatcmpl-f51b2cd2-bef7-417e-964e-a08f0b513c22")
        XCTAssertEqual(response.object, "chat.completion")
        XCTAssertEqual(response.created, 1730241104)
        XCTAssertEqual(response.model, "llama3-8b-8192")
        XCTAssertEqual(response.choices.count, 1)
        XCTAssertEqual(response.choices[0].index, 0)
        XCTAssertEqual(response.choices[0].message.role, .assistant)
        XCTAssertEqual(response.choices[0].message.content, "This is a test response")
        XCTAssertEqual(response.choices[0].finishReason, "stop")
        XCTAssertNil(response.choices[0].logprobs)
        XCTAssertEqual(response.usage?.queueTime, 0.037493756)
        XCTAssertEqual(response.usage?.promptTokens, 18)
        XCTAssertEqual(response.usage?.promptTime, 0.000680594)
        XCTAssertEqual(response.usage?.completionTokens, 556)
        XCTAssertEqual(response.usage?.completionTime, 0.463333333)
        XCTAssertEqual(response.usage?.totalTokens, 574)
        XCTAssertEqual(response.usage?.totalTime, 0.464013927)
        XCTAssertEqual(response.systemFingerprint, "fp_179b0f92c9")
        XCTAssertEqual(response.xGroq?.id, "req_01jbd6g2qdfw2adyrt2az8hz4w")
    }
}
