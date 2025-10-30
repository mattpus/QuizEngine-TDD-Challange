//
//  CountryQuestionInterpreting.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

public protocol CountryQuestionInterpreting {
    func interpret(_ question: String) async -> CountryQuery
}
