//
//  ChatViewModel.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation
import QuizEngineCore
import Combine

final class ChatViewModel: ObservableObject {
    @Published public private(set) var messages: [ChatMessage] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: ErrorMessage?

    private let engine: AnswerProvider
    private var lastQuestion: String?
    
    public var canRetry: Bool {
        lastQuestion != nil
    }
    
    public init(engine: AnswerProvider) {
        self.engine = engine
    }
    
    public func send(question: String) async {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        lastQuestion = question
        messages.append(ChatMessage(role: .user, text: question))
        await answer(question, appendUserMessage: false)
    }
    
    private func answer(_ question: String, appendUserMessage: Bool) async {
        if appendUserMessage {
            messages.append(ChatMessage(role: .user, text: question))
        }

        isLoading = true
        self.error = nil

        do {
            let response = try await engine.answer(for: question)
            messages.append(ChatMessage(role: .assistant, text: response.text, imageURL: response.imageURL))
            self.error = nil
        } catch {
            self.error = .dataUnavailable
        }

        isLoading = false
    }
}
