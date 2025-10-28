//
//  AnswerProvider.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

public protocol AnswerProvider {
    func answer(for question: String) async throws -> CountryAnswer
}
