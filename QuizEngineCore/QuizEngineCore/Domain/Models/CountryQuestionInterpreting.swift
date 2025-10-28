//
//  CountryQuestionInterpreting.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

public protocol CountryQuestionInterpreting {
    /// Parses the raw text into a structured `CountryQuery`.
    func interpret(_ question: String) -> CountryQuery
}
