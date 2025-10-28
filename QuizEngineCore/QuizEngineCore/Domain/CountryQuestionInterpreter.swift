//
//  CountryQuestionInterpreter.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

public final class CountryQuestionInterpreter: CountryQuestionInterpreting {
    
    public init() {}

    public func interpret(_ question: String) -> CountryQuery {
      return .capital(of: question)
    }
}
