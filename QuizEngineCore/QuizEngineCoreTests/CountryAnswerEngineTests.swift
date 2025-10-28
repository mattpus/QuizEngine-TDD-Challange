import XCTest
@testable import QuizEngineCore

final class AnswerEngineTests: XCTestCase {
    func test_answerProvidesCapitalForKnownCountry() async throws {
        let countries = [makeCountry(name: "Belgium", capitals: ["Brussels"], iso: "BE", flagEmoji: "🇧🇪")]
        let sut = makeSUT(countries: countries)

        let answer = try await sut.answer(for: "test")

        XCTAssertEqual(answer.text, "text")
        XCTAssertNil(answer.imageURL)
    }

    

    // MARK: - Helpers

    private func makeSUT(countries: [Country], file: StaticString = #file, line: UInt = #line) -> AnswerEngine {
        let loader = CountryLoaderSpy(result: .success(countries))
        let sut = AnswerEngine(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func makeCountry(name: String, capitals: [String], iso: String, flagEmoji: String?, flagURL: URL? = nil) -> Country {
        Country(name: name, capitalCities: capitals, isoCode: iso, flagEmoji: flagEmoji, flagImageURL: flagURL)
    }
}

private final class CountryLoaderSpy: CountryLoader {
    private(set) var loadCallCount = 0
    private let result: Result<[Country], Error>

    init(result: Result<[Country], Error>) {
        self.result = result
    }

    func loadCountries() async throws -> [Country] {
        loadCallCount += 1
        return try result.get()
    }
}
