//
//  ChatViewModelTests.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import XCTest
import QuizEngineCore
@testable import QuizEngineiOS

final class ChatViewModelTests: XCTestCase {
    func test_chatViewModel_initialization() {
        let engine = AnswerEngineSpy(result: .success(CountryAnswer(text: "The capital of Belgium is Brussels.", imageURL: nil)))
        let sut = makeSUT(engine: engine)
        XCTAssertNotNil(sut)
    }
    
    func test_chatViewModel_send_appendsUserAndAssistantMessagesOnSuccess() async {
        let engine = AnswerEngineSpy(result: .success(CountryAnswer(text: "The capital of Belgium is Brussels.", imageURL: nil)))
        let sut = makeSUT(engine: engine)
        
        await sut.send(question: "What is the capital of Belgium?")
        
        XCTAssertEqual(sut.messages.count, 2)
        XCTAssertEqual(sut.messages[0].role, .user)
        XCTAssertEqual(sut.messages[0].text, "What is the capital of Belgium?")
        XCTAssertEqual(sut.messages[1].role, .assistant)
        XCTAssertEqual(sut.messages[1].text, "The capital of Belgium is Brussels.")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
        XCTAssertTrue(sut.canRetry)
    }
    
    func test_sendStoresErrorWhenEngineFails() async {
        let engine = AnswerEngineSpy(result: .failure(.dataUnavailable))
        let sut = makeSUT(engine: engine)

        await sut.send(question: "Capital of Belgium")

        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertEqual(sut.messages[0].role, .user)
        XCTAssertEqual(sut.messages[0].text, "Capital of Belgium")
        XCTAssertEqual(sut.error?.message, ErrorMessage.dataUnavailable.message)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.canRetry)
    }
    
    func test_retryUsesLastQuestionAfterFailure() async {
        let results: [Result<CountryAnswer, AnswerEngine.Error>] = [
            .failure(.dataUnavailable),
            .success(CountryAnswer(
                text: "The capital of Belgium is Brussels.",
                imageURL: nil))
        ]
        let engine = AnswerEngineSpy(results: results)
        let sut = makeSUT(engine: engine)

        await sut.send(question: "Capital of Belgium")
        await sut.retry()

        XCTAssertEqual(engine.receivedQuestions, ["Capital of Belgium", "Capital of Belgium"])
        XCTAssertEqual(sut.messages.count, 2)
        XCTAssertEqual(sut.messages.last?.text, "The capital of Belgium is Brussels.")
        XCTAssertNil(sut.error)
    }
    
    private func makeSUT(engine: AnswerEngineSpy, file: StaticString = #file, line: UInt = #line) -> ChatViewModel {
        let sut = ChatViewModel(engine: engine)
        trackForMemoryLeaks(engine, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

private final class AnswerEngineSpy: AnswerProvider {
    private var results: [Result<CountryAnswer, AnswerEngine.Error>]
    private(set) var receivedQuestions: [String] = []
    init(result: Result<CountryAnswer, AnswerEngine.Error>) {
        self.results = [result]
    }
    
    init(results: [Result<CountryAnswer, AnswerEngine.Error>]) {
        self.results = results
    }
    
    func answer(for question: String) async throws -> CountryAnswer {
        receivedQuestions.append(question)
        guard !results.isEmpty else {
            XCTFail("Unexpected call")
            return CountryAnswer(text: "", imageURL: nil)
        }
        let result = results.removeFirst()
        switch result {
        case let .success(answer):
            return answer
        case let .failure(error):
            throw error
        }    }
}
