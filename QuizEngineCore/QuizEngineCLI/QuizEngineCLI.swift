//
//  QuizEngineCLI.swift
//  QuizEngineCLI
//
//  Created by Matt on 29/10/2025.
//

import Foundation
import QuizEngineCore

public final class QuizEngineCLIApp {
    private let io: ChatIO
    private let engine: AnswerProvider
    private var lastQuestion: String?

    public init(io: ChatIO, engine: AnswerProvider) {
        self.io = io
        self.engine = engine
    }

    public func run() async {
        printWelcome()

        while true {
            io.writePrompt("> ")

            guard let input = io.readLine() else {
                io.write("👋 Goodbye!")
                break
            }

            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if let command = Command.from(trimmed) {
                switch command {
                case .exit, .quit:
                    io.write("👋 Goodbye!")
                    return
                case .retry:
                    guard let previous = lastQuestion else {
                        io.write("There's nothing to retry yet. Ask a question first.")
                        continue
                    }
                    await answer(previous)
                }
                continue
            }

            lastQuestion = input
            await answer(input)
        }
    }

    private func answer(_ question: String) async {
        do {
            let response = try await engine.answer(for: question)
            io.write(TerminalOutputStyling.assistant("🤖 \(response.text)"))
            if let url = response.imageURL {
                io.write(TerminalOutputStyling.info(url.absoluteString))
            }
        } catch {
            io.write(TerminalOutputStyling.warning("⚠️ I couldn't fetch the latest country information. Check your connection and type 'retry' to try again or 'exit' to quit."))
        }
    }

    private func printWelcome() {
        io.write(TerminalOutputStyling.banner("🌍 Country Info Chat"))
        io.write(TerminalOutputStyling.subtitle("Ask me about capitals, ISO codes, flags, or countries by prefix."))
        io.write(TerminalOutputStyling.subtitle("Type 'exit' to quit."))
        io.write(TerminalOutputStyling.subtitle("Type 'retry' to repeat the last question."))
        io.write(TerminalOutputStyling.examples([
            "What is the capital of Belgium?",
            "Which countries start with CH?",
            "What is the ISO alpha-2 country code for Greece?",
            "What is the flag of Brazil?"
        ]))
    }
}
