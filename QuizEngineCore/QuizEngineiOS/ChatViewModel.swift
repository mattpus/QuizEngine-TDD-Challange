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
    private let engine: AnswerProvider
    public init(engine: AnswerProvider) {
        self.engine = engine
    }
}
