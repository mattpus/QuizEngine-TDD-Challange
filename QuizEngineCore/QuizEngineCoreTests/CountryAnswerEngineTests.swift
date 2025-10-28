import XCTest
@testable import QuizEngineCore

final class AnswerEngineTests: XCTestCase {
    func test_answerProvidesCapitalForKnownCountry() async throws {
        let countries = [makeCountry(name: "Belgium", capitals: ["Brussels"], iso: "BE", flagEmoji: "🇧🇪")]
        let sut = makeSUT(countries: countries)

        let answer = try await sut.answer(for: "What's the capital of Belgium?")

        XCTAssertEqual(answer.text, "The capital of Belgium is Brussels.")
        XCTAssertNil(answer.imageURL)
    }
    
    func test_answerProvidesAllCapitalsIfMultiple() async throws {
        let countries = [makeCountry(name: "South Africa", capitals: ["Pretoria", "Bloemfontein", "Cape Town"], iso: "ZA", flagEmoji: "🇿🇦")]
        let sut = makeSUT(countries: countries)

        let answer = try await sut.answer(for: "Capital of south africa")

        XCTAssertEqual(answer.text, "The capitals of South Africa are Pretoria, Bloemfontein and Cape Town.")
    }
    
    func test_answerHandlesUnknownCountryGracefully() async throws {
        let sut = makeSUT(countries: [])

        let answer = try await sut.answer(for: "Capital of Wakanda")

        XCTAssertEqual(answer.text, "I couldn't find information about Wakanda.")
    }
    
    func test_answerHandlesUnknownQuestionGracefully() async throws {
        let sut = makeSUT(countries: [])

        let answer = try await sut.answer(for: "How tall is Mount Everest?")

        XCTAssertEqual(answer.text, "I'm not sure how to answer that yet, but I can help with country capitals, codes, flags, or names by prefix.")
    }
    
    func test_answerCachesCountriesAfterFirstLoad() async throws {
        let countries = [makeCountry(name: "Belgium", capitals: ["Brussels"], iso: "BE", flagEmoji: "🇧🇪")]
        let loader = CountryLoaderSpy(result: .success(countries))
        let sut = AnswerEngine(loader: loader)

        _ = try await sut.answer(for: "Capital of Belgium")
        _ = try await sut.answer(for: "ISO code for Belgium")

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_answerPropagatesLoaderErrors() async {
        let loader = CountryLoaderSpy(result: .failure(anyNSError()))
        let sut = AnswerEngine(loader: loader)

        do {
            _ = try await sut.answer(for: "Capital of Belgium")
            XCTFail("Expected to throw")
        } catch {
            XCTAssertEqual(error as? AnswerEngine.Error, .dataUnavailable)
        }
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
