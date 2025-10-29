//
//  TerminalOutputStyling.swift
//  QuizEngineCore
//
//  Created by Matt on 29/10/2025.
//

import Foundation

enum TerminalOutputStyling {
    private static let reset = "\u{001B}[0m"

    static func banner(_ text: String) -> String {
        "\u{001B}[1;94m\(text)\(reset)"
    }

    static func subtitle(_ text: String) -> String {
        "\u{001B}[36m\(text)\(reset)"
    }

    static func examples(_ lines: [String]) -> String {
        let header = "\u{001B}[35mExamples:\(reset)"
        let formatted = lines.map { "  • \( $0 )" }.joined(separator: "\n")
        return "\(header)\n\(formatted)"
    }

    static func assistant(_ text: String) -> String {
        "\u{001B}[32m\(text)\(reset)"
    }

    static func info(_ text: String) -> String {
        "\u{001B}[2m\(text)\(reset)"
    }

    static func warning(_ text: String) -> String {
        "\u{001B}[33m\(text)\(reset)"
    }
}
