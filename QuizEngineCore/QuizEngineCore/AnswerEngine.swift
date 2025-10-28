//
//  AnswerEngine.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

public final class AnswerEngine {
    public enum Error: Swift.Error, Equatable {
        case dataUnavailable
    }
    
    private let loader: CountryLoader
    private var cachedCountries: [Country]?
    
    public init(loader: CountryLoader) {
        self.loader = loader
    }
    
    public func answer(for question: String) async throws -> CountryAnswer {
        return CountryAnswer(text: "text", imageURL: nil)
    }
}
