//
//  CountryQuestionInterpreter.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

public final class CountryQuestionInterpreter: CountryQuestionInterpreting {
    
    public init() {}
    
    /// tolerance of wrong characters, that user can make when typing
    private let tolerance = 2

    public func interpret(_ question: String) -> CountryQuery {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unknown(question) }
        
        let normalized = NormalizedQuestion(original: trimmed)
        let strategies: [(NormalizedQuestion) -> CountryQuery?] = [
            checkIfCapital,
            checkIfISO,
            checkIfFlag,
            checkIfCountry
        ]

        guard let matchedQuery = strategies.compactMap({ $0(normalized) }).first else {
            return .unknown(trimmed)
        }
        return matchedQuery
    }
    
    // MARK: - Strategies to match the question with the answer
    
    private func checkIfCapital(question: NormalizedQuestion) -> CountryQuery? {
        if question.fuzzyContains("capital", tolerance: tolerance) {
            if let subject = question.argument(after: ["capital of", "capital for", "capital city of", "capital city for"])
                ?? question.argument(afterPrepositions: ["of", "for"]) {
                return .capital(of: subject)
            }
        }
        return nil
    }
    
    private func checkIfISO(question: NormalizedQuestion) -> CountryQuery? {
        if question.fuzzyContains("iso", tolerance: tolerance) || question.contains("alpha-2") || question.contains("alpha2") {
            if question.fuzzyContains("code", tolerance: tolerance) {
                if let subject = question.argument(after: ["code for", "code of", "for", "of"])
                    ?? question.argument(afterPrepositions: ["for", "of"]) {
                    return .isoCode(of: subject)
                }
            }
        }
        return nil
    }
    
    private func checkIfFlag(question: NormalizedQuestion) -> CountryQuery? {
        if question.fuzzyContains("flag", tolerance: tolerance) {
            if let subject = question.argument(after: ["flag of", "flag for", "for", "of"])
                ?? question.argument(afterPrepositions: ["for", "of"]) {
                return .flag(of: subject)
            }
        }
        return nil
    }
    
    private func checkIfCountry(question: NormalizedQuestion) -> CountryQuery? {
        if question.contains("countries") || question.contains("country") {
            if question.fuzzyContains("start", tolerance: tolerance) || question.fuzzyContains("begin", tolerance: tolerance) {
                if question.fuzzyContains("with", tolerance: tolerance) {
                    if let prefix = question.argument(after: ["start with", "starting with", "begin with", "beginning with", "with"]) {
                        let sanitized = prefix
                            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
                            .first
                            .map { String($0) } ?? prefix
                        return .countriesStartingWith(prefix: sanitized.uppercased())
                    }
                }
            }
        }
        return nil
    }
}
