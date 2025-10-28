//
//  Helpers.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

func formatList(_ values: [String]) -> String {
    guard let first = values.first else { return "" }
    if values.count == 1 {
        return first
    }
    if values.count == 2 {
        return values.joined(separator: " and ")
    }
    var copy = values
    let last = copy.removeLast()
    return copy.joined(separator: ", ") + " and " + last
}

func normalize(_ value: String) -> String {
    value
        .folding(options: .diacriticInsensitive, locale: .current)
        .lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .joined()
}

/// Levenshtein distance (edit distance)
/// Measures how many single-character edits (insertions, deletions, substitutions)
/// are needed to transform one string into another.
///
/// This implementation uses a classic dynamic programming approach optimized to
/// keep only a single row of the DP matrix in memory (plus a few temporaries),
/// reducing space from O(m*n) to O(min(m, n))) while keeping time O(m*n), where
/// m = lhs.count and n = rhs.count.
///
func levenshtein(_ lhs: String, _ rhs: String) -> Int {
    if lhs == rhs { return 0 }
    let lhsChars = Array(lhs)
    let rhsChars = Array(rhs)

    if lhsChars.isEmpty { return rhsChars.count }
    if rhsChars.isEmpty { return lhsChars.count }

    var distances = Array(0...rhsChars.count)

    for (i, lhsChar) in lhsChars.enumerated() {
        var previous = distances[0]
        distances[0] = i + 1

        for (j, rhsChar) in rhsChars.enumerated() {
            let cost = lhsChar == rhsChar ? 0 : 1
            let insertion = distances[j] + 1
            let deletion = distances[j + 1] + 1
            let substitution = previous + cost
            previous = distances[j + 1]
            distances[j + 1] = min(insertion, deletion, substitution)
        }
    }

    return distances.last ?? 0
}
