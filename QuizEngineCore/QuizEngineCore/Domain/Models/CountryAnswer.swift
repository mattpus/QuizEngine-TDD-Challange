//
//  CountryAnswer.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

public struct CountryAnswer: Equatable, Sendable {
    public let text: String
    public let imageURL: URL?

    public init(text: String, imageURL: URL? = nil) {
        self.text = text
        self.imageURL = imageURL
    }
}
