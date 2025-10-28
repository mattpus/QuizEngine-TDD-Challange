//
//  CountryQuery.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

public enum CountryQuery: Equatable {
    /// Asks for the capital city of a country.
    case capital(of: String)
    /// Requests the ISO alpha-2 code for a country.
    case isoCode(of: String)
    /// Requests information about the national flag.
    case flag(of: String)
    /// Requests a list of countries starting with the provided prefix.
    case countriesStartingWith(prefix: String)
    /// A fallback when the interpreter cannot determine a supported intent.
    case unknown(String)
}

