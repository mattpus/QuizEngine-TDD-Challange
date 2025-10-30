//
//  CountryQuestionInterpreter.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation
import FoundationModels

public final class CountryQuestionInterpreter: CountryQuestionInterpreting {
    
    private let session: LanguageModelSession
    
    public init(session: LanguageModelSession? = nil) {
        self.session = session ?? LanguageModelSession(instructions: Self.instructionText)
    }
    
    private static let instructionText: String = """
    You are a country question interpreter. Given a natural-language question, determine the most appropriate CountryQuery:
    - capital: when the user asks for the capital of a country.
    - isoCode: when the user asks for the country ISO/alpha-2 code.
    - flag: when the user asks to see the flag of a country.
    - countriesstartingwith: when the user asks for countries that start with a given prefix.
    - unknown: when no pattern matches; include the original question.

    Rules:
    - Be robust to minor typos. If the user writes words close to key terms (e.g., "capitel" ≈ "capital"), treat them as matches when within edit distance <= 2.
    - Extract the subject (country name or prefix) after phrases like "capital of", "code for", or prepositions like "of"/"for".
    - For starting-with queries, return the uppercase prefix without surrounding whitespace.
    - Avoid making up country names; if you cannot identify a subject, return .unknown.
    """
 
    public func interpret(_ question: String) async -> CountryQuery {
        do {
            let prompt = Prompt("Answer the return the most appropriate QuestionQuery for this question from the user: \(question)")

            let response = try await session.respond(to: prompt, generating: QuestionQuery.self)
            return mapToCountryQuery(from: response.content)
        } catch {
            return .unknown("Error processing question: \(question)")
        }
    }
    
    private func mapToCountryQuery(from question: QuestionQuery) -> CountryQuery {
        switch question.type.lowercased() {
        case "capital":
            return .capital(of: question.country)
        case "isocode", "iso", "alpha2", "alpha-2":
            return .isoCode(of: question.country)
        case "flag":
            return .flag(of: question.country)
        case "startswith", "countriesstartingwith":
            return .countriesStartingWith(prefix: question.countryPrefix)
        default:
            return .unknown("Unrecognized type of question")
        }
    }
}

@Generable
private struct QuestionQuery {
    let country: String
    let type: String
    let countryPrefix: String
}
