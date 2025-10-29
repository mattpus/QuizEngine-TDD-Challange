//
//  AnswerEngine.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import Foundation

public final class AnswerEngine: AnswerProvider {
    private let loader: CountryLoader
    private let interpreter: CountryQuestionInterpreting
    private var cachedCountries: [Country]?
    
    public init(loader: CountryLoader,
                interpreter: CountryQuestionInterpreting = CountryQuestionInterpreter()) {
        self.loader = loader
        self.interpreter = interpreter
    }
    
    public enum Error: Swift.Error, Equatable {
        case dataUnavailable
    }
    
    public func answer(for question: String) async throws -> CountryAnswer {
        let query = interpreter.interpret(question)

        switch query {
        case let .capital(of: name):
            let countries = try await loadCountries()
            return capitalAnswer(for: name, countries: countries)
        case let .countriesStartingWith(prefix):
            let countries = try await loadCountries()
            return countriesStartingWithAnswer(for: prefix, countries: countries)
        case let .isoCode(of: name):
            let countries = try await loadCountries()
            return isoAnswer(for: name, countries: countries)
        case let .flag(of: name):
            let countries = try await loadCountries()
            return flagAnswer(for: name, countries: countries)
        case .unknown:
            return CountryAnswer(
                text: "I'm not sure how to answer that yet, but I can help with country capitals, codes, flags, or names by prefix.",
                imageURL: nil
            )
        }
    }
    
    private func loadCountries() async throws -> [Country] {
        if let cachedCountries {
            return cachedCountries
        }

        do {
            let countries = try await loader.loadCountries()
            cachedCountries = countries
            return countries
        } catch {
            throw Error.dataUnavailable
        }
    }
    
    // MARK: - Methods to create an anwers based on queries
    
    private func isoAnswer(for rawName: String, countries: [Country]) -> CountryAnswer {
        guard let match = findCountry(matching: rawName, in: countries) else {
            return CountryAnswer(text: "I couldn't find information about \(rawName).", imageURL: nil)
        }

        return CountryAnswer(text: "The ISO alpha-2 code for \(match.name) is \(match.isoCode.uppercased()).", imageURL: nil)
    }

    private func capitalAnswer(for rawName: String, countries: [Country]) -> CountryAnswer {
        guard let match = findCountry(matching: rawName, in: countries) else {
            return CountryAnswer(text: "I couldn't find information about \(rawName).", imageURL: nil)
        }

        let capitals = match.capitalCities
        guard !capitals.isEmpty else {
            return CountryAnswer(text: "I couldn't find capital information for \(match.name).", imageURL: nil)
        }

        let formattedCapitals = formatList(capitals)
        if capitals.count == 1 {
            return CountryAnswer(text: "The capital of \(match.name) is \(formattedCapitals).", imageURL: nil)
        } else {
            return CountryAnswer(text: "The capitals of \(match.name) are \(formattedCapitals).", imageURL: nil)
        }
    }
    
    private func flagAnswer(for rawName: String, countries: [Country]) -> CountryAnswer {
        guard let match = findCountry(matching: rawName, in: countries) else {
            return CountryAnswer(text: "I couldn't find information about \(rawName).", imageURL: nil)
        }

        if let emoji = match.flagEmoji, !emoji.isEmpty {
            return CountryAnswer(text: "The flag of \(match.name) is \(emoji).", imageURL: match.flagImageURL)
        }

        if let url = match.flagImageURL {
            return CountryAnswer(text: "Here's the flag of \(match.name): \(url.absoluteString)", imageURL: url)
        }

        return CountryAnswer(text: "I couldn't find the flag for \(match.name).", imageURL: nil)
    }

    private func findCountry(matching rawName: String, in countries: [Country]) -> Country? {
        let normalizedInput = normalize(rawName)
        var bestMatch: (country: Country, distance: Int)?

        for country in countries {
            let normalizedCandidate = normalize(country.name)

            if normalizedCandidate == normalizedInput || normalizedCandidate.contains(normalizedInput) || normalizedInput.contains(normalizedCandidate) {
                return country
            }

            let distance = levenshtein(normalizedCandidate, normalizedInput)
            let threshold = max(1, Int(Double(max(normalizedCandidate.count, normalizedInput.count)) * 0.3))

            if distance <= threshold {
                if bestMatch == nil || distance < bestMatch!.distance {
                    bestMatch = (country, distance)
                }
            }
        }

        return bestMatch?.country
    }
    
    private func countriesStartingWithAnswer(for prefix: String, countries: [Country]) -> CountryAnswer {
        let normalizedPrefix = normalize(prefix)
        let matching = countries
            .filter { normalize($0.name).hasPrefix(normalizedPrefix) }
            .sorted { $0.name < $1.name }
            .map(\.name)

        guard !matching.isEmpty else {
            return CountryAnswer(text: "I couldn't find countries that start with \(prefix.uppercased()).", imageURL: nil)
        }

        let list = matching.joined(separator: ", ")
        return CountryAnswer(text: "Countries that start with \(prefix.uppercased()): \(list).", imageURL: nil)
    }
}
