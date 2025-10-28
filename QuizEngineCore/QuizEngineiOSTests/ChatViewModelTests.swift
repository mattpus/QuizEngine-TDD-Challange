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
    
    func test_ChatViewModel_Initialization() {
        let engine = AnswerEngineSpy(result: .success(CountryAnswer(text: "The capital of Belgium is Brussels.", imageURL: nil)))
        let sut = makeSUT(engine: engine)
       XCTAssertNotNil(sut)
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
   

    init(result: Result<CountryAnswer, AnswerEngine.Error>) {
        self.results = [result]
    }


    func answer(for question: String) async throws -> CountryAnswer {
        return try results.first!.get()
    }
}
