#if DEBUG
import Foundation
import QuizEngineCore
import QuizEngineiOS

struct UITestConfiguration: Codable {
    let responses: [UITestResponse]
}

struct UITestResponse: Codable {
    enum Result: String, Codable {
        case success
        case failure
    }

    let result: Result
    let text: String?
    let imageURL: URL?
}

actor UITestAnswerEngine: AnswerProvider {
    private var queue: [UITestResponse]

    init(responses: [UITestResponse]) {
        self.queue = responses
    }

    func answer(for question: String) async throws -> CountryAnswer {
        guard !queue.isEmpty else {
            return CountryAnswer(text: "No stub response available for \(question).", imageURL: nil)
        }

        let next = queue.removeFirst()
        switch next.result {
        case .success:
            return CountryAnswer(text: next.text ?? "", imageURL: next.imageURL)
        case .failure:
            throw AnswerEngine.Error.dataUnavailable
        }
    }
}

enum UITestSupport {
    static func makeViewModelIfNeeded() -> ChatViewModel? {
        guard ProcessInfo.processInfo.arguments.contains("UITesting") else {
            return nil
        }

        let responses = decodeResponses()
        return ChatViewModel(engine: UITestAnswerEngine(responses: responses))
    }

    private static func decodeResponses() -> [UITestResponse] {
        guard
            let rawValue = ProcessInfo.processInfo.environment["UITEST_RESPONSES"],
            let data = rawValue.data(using: .utf8),
            let configuration = try? JSONDecoder().decode(UITestConfiguration.self, from: data)
        else {
            return []
        }

        return configuration.responses
    }
}
#endif
