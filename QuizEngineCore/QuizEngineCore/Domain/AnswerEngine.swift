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
    private let interpreter: CountryQuestionInterpreting
    private var cachedCountries: [Country]?
    
    public init(loader: CountryLoader,
                interpreter: CountryQuestionInterpreting = CountryQuestionInterpreter()) {
        self.loader = loader
        self.interpreter = interpreter
    }
    
    public func answer(for question: String) async throws -> CountryAnswer {
        let query = interpreter.interpret(question)
        let countries = try await loadCountries()
        switch query {
        case let .capital(of: name):
            return CountryAnswer(text: "capital \(name)")

        case let .isoCode(of: name):
            return CountryAnswer(text: "isoCode \(name)")

        case let .flag(of: name):
            return CountryAnswer(text: "flag \(name)")

        case let .countriesStartingWith(prefix):
            return CountryAnswer(text: "countriesStartingWith \(prefix)")
        case .unknown:
            return CountryAnswer(
                text: "unknown")
        }
    }
    
    private func loadCountries() async throws -> [Country] {
        if let cachedCountries {
            return cachedCountries
        }

        do {
            let countries = try await loader.loadCountries()
            cachedCountries = countries
            return countries
        } catch {
            throw Error.dataUnavailable
        }
    }
}
