import XCTest
@testable import GroqSwift

// swiftlint:disable all
final class ChatCompletionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
    }

    func testSuccessfulChatCompletion() async throws {
        let mockData = """
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
                    "finish_reason": "stop"
                }
            ],
            "usage": {
                "prompt_tokens": 10,
                "completion_tokens": 5,
                "total_tokens": 15,
                "queue_time": 0.037493756,
                "prompt_time": 0.000680594,
                "completion_time": 0.463333333,
                "total_time": 0.464013927
            }
        }
        """

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)

        MockURLProtocol.mockData = mockData.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.groq.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let client = await GroqClient(apiKey: "test-key", session: session)
        let request = ChatCompletionRequest(
            model: "llama3-8b-8192",
            messages: [
                Message(role: .user, content: "Tell me about fast language models")
            ]
        )

        let response = try await client.createChatCompletion(request)

        XCTAssertEqual(response.id, "chatcmpl-f51b2cd2-bef7-417e-964e-a08f0b513c22")
        XCTAssertEqual(response.choices.count, 1)
        XCTAssertEqual(response.choices[0].message.content, "This is a test response")
        XCTAssertEqual(response.usage?.promptTokens, 10)
        XCTAssertEqual(response.usage?.completionTokens, 5)
        XCTAssertEqual(response.usage?.totalTokens, 15)
        XCTAssertEqual(response.usage?.queueTime, 0.037493756)
        XCTAssertEqual(response.usage?.promptTime, 0.000680594)
        XCTAssertEqual(response.usage?.completionTime, 0.463333333)
        XCTAssertEqual(response.usage?.totalTime, 0.464013927)
    }

    func testErrorResponse() async throws {
        let errorJSON = """
        {
            "error": {
                "message": "Invalid API key",
                "type": "invalid_request_error",
                "param": null,
                "code": null
            }
        }
        """

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)

        MockURLProtocol.mockData = errorJSON.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.groq.com/v1/chat/completions")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        let client = await GroqClient(apiKey: "invalid-key", session: session)
        let request = ChatCompletionRequest(
            model: "llama3-8b-8192",
            messages: [
                Message(role: .user, content: "Test message")
            ]
        )

        do {
            _ = try await client.createChatCompletion(request)
            XCTFail("Expected error but got success")
        } catch let error as GroqError {
            switch error {
            case .authenticationFailed(let message):
                XCTAssertEqual(message, "Invalid API key")
            default:
                XCTFail("Expected authentication error but got \(error)")
            }
        }
    }
}

// swiftlint:enable all
