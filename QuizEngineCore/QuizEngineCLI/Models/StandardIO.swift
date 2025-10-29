//
//  StandardIO.swift
//  QuizEngineCore
//
//  Created by Matt on 29/10/2025.
//

import Foundation

public struct StandardIO: ChatIO {
    public init() {}

    public func write(_ text: String) {
        print(text)
    }

    public func writePrompt(_ prompt: String) {
        print(prompt, terminator: "")
        fflush(stdout)
    }

    public func readLine() -> String? {
        Swift.readLine()
    }
}
