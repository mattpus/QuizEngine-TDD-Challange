//
//  NormalizedQuestion.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

/// This struct helps to check if the user made any typos and
/// correct the question if needed
struct NormalizedQuestion {
    private let original: String
    private let lowercased: String
    private let tokens: [String]

    init(original: String) {
        self.original = original
        self.lowercased = original.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
        self.tokens = lowercased.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }

    func contains(_ phrase: String) -> Bool {
        lowercased.contains(phrase)
    }

    func fuzzyContains(_ keyword: String, tolerance: Int) -> Bool {
        tokens.contains { token in
            levenshtein(token, keyword) <= tolerance
        }
    }

    func argument(after keywords: [String]) -> String? {
        for keyword in keywords {
            if let result = argument(after: keyword) {
                return result
            }
        }
        return nil
    }

    func argument(afterPrepositions prepositions: [String]) -> String? {
        for preposition in prepositions {
            if let result = argument(afterPreposition: preposition) {
                return result
            }
        }
        return nil
    }

    private func argument(after keyword: String) -> String? {
        guard let range = lowercased.range(of: keyword) else {
            return nil
        }

        let start = range.upperBound
        let substring = original[start...]
        let trimmed = substring.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
        return trimmed.isEmpty ? nil : trimmed
    }

    private func argument(afterPreposition preposition: String) -> String? {
        let target = " \(preposition) "

        if let range = lowercased.range(of: target, options: [.backwards]) {
            let substring = original[range.upperBound...]
            let trimmed = substring.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            return trimmed.isEmpty ? nil : trimmed
        }

        if let range = lowercased.range(of: "\(preposition) ", options: [.backwards]) {
            let substring = original[range.upperBound...]
            let trimmed = substring.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            return trimmed.isEmpty ? nil : trimmed
        }

        return nil
    }
}
