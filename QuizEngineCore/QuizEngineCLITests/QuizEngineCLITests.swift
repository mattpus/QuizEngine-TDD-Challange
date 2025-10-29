//
//  QuizEngineCLITests.swift
//  QuizEngineCLITests
//
//  Created by Matt on 29/10/2025.
//

import XCTest
import QuizEngineCore
@testable import QuizEngineCLI

final class QuizEngineCLITests: XCTestCase {
    func test_chatAnswersQuestionAndExits() async throws {
        let io = TestIO(inputs: ["What is the capital of Belgium?", "exit"])
        let engine = AnswerEngineSpy(outputs: [
            .success(CountryAnswer(text: "The capital of Belgium is Brussels.", imageURL: nil))
        ])
        let sut = QuizEngineCLIApp(io: io, engine: engine)

        await sut.run()

        XCTAssertEqual(engine.receivedQuestions, ["What is the capital of Belgium?"])
        XCTAssertTrue(io.outputs.contains { $0.contains("The capital of Belgium is Brussels.") })
        XCTAssertTrue(io.outputs.contains { $0.contains("Type 'exit' to quit") })
        XCTAssertTrue(io.outputs.contains { $0.contains("Type 'retry' to repeat the last question") })
        XCTAssertTrue(io.outputs.contains { $0.contains("Examples:") })
        XCTAssertTrue(io.outputs.contains { $0.contains("Which countries start with CH?") })
        XCTAssertTrue(io.outputs.contains { $0.contains("👋 Goodbye!") })
    }

    func test_retryAfterErrorReusesLastQuestion() async throws {
        let io = TestIO(inputs: ["Capital of Belgium", "retry", "exit"])
        let engine = AnswerEngineSpy(outputs: [
            .failure(AnswerEngine.Error.dataUnavailable),
            .success(CountryAnswer(text: "The capital of Belgium is Brussels.", imageURL: nil))
        ])
        let sut = QuizEngineCLIApp(io: io, engine: engine)

        await sut.run()

        XCTAssertEqual(engine.receivedQuestions, ["Capital of Belgium", "Capital of Belgium"])
        XCTAssertTrue(io.outputs.contains { $0.contains("couldn't fetch") })
        XCTAssertTrue(io.outputs.contains { $0.contains("The capital of Belgium is Brussels.") })
    }

    func test_retryWithoutPreviousQuestionInformsUser() async throws {
        let io = TestIO(inputs: ["retry", "exit"])
        let engine = AnswerEngineSpy(outputs: [])
        let sut = QuizEngineCLIApp(io: io, engine: engine)

        await sut.run()

        XCTAssertEqual(engine.receivedQuestions, [])
        XCTAssertTrue(io.outputs.contains { $0.contains("Ask a question first") })
    }
}

private final class TestIO: ChatIO {
    private var inputs: [String]
    private(set) var outputs: [String] = []

    init(inputs: [String]) {
        self.inputs = inputs
    }

    func write(_ text: String) {
        outputs.append(stripANSICodes(from: text))
    }

    func writePrompt(_ prompt: String) {
        outputs.append(stripANSICodes(from: prompt))
    }

    func readLine() -> String? {
        guard !inputs.isEmpty else { return nil }
        return inputs.removeFirst()
    }

    private func stripANSICodes(from text: String) -> String {
        var result = ""
        var iterator = text.makeIterator()
        var skipping = false

        while let char = iterator.next() {
            if skipping {
                if char == "m" {
                    skipping = false
                }
                continue
            }
            if char == "\u{001B}" {
                skipping = true
                continue
            }
            result.append(char)
        }
        return result
    }
}

private final class AnswerEngineSpy: AnswerProvider {
    private var outputs: [Result<CountryAnswer, Error>]
    private(set) var receivedQuestions: [String] = []

    init(outputs: [Result<CountryAnswer, Error>]) {
        self.outputs = outputs
    }

    func answer(for question: String) async throws -> CountryAnswer {
        receivedQuestions.append(question)
        guard !outputs.isEmpty else {
            XCTFail("Unexpected call")
            return CountryAnswer(text: "", imageURL: nil)
        }
        let result = outputs.removeFirst()
        switch result {
        case let .success(answer):
            return answer
        case let .failure(error):
            throw error
        }
    }
}
