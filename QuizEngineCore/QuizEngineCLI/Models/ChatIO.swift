//
//  ChatIO.swift
//  QuizEngineCore
//
//  Created by Matt on 29/10/2025.
//

public protocol ChatIO {
    func write(_ text: String)
    func writePrompt(_ prompt: String)
    func readLine() -> String?
}
