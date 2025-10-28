//
//  ErrorMessage.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

public struct ErrorMessage: Identifiable, Equatable {
    public let id = UUID()
    public let message: String

    public static let dataUnavailable = ErrorMessage(message: "I couldn't fetch country information. Please try again.")
}
