//
//  CountryLoader.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

public protocol CountryLoader: AnyObject {
    func loadCountries() async throws -> [Country]
}
