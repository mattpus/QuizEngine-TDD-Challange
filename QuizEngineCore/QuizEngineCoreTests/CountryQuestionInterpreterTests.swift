import XCTest
@testable import QuizEngineCore

@MainActor
final class CountryQuestionInterpreterTests: XCTestCase {
    func test_interpretsCapitalQuestion() async {
        let sut = makeSUT()

        let query = await sut.interpret("What is the capital of Belgium?")

        XCTAssertEqual(query, .capital(of: "Belgium"))
    }

    func test_interpretsCapitalQuestionWithMisspelling() async {
        let sut = makeSUT()

        let query = await sut.interpret("Tell me the capitel of argentine")

        XCTAssertEqual(query, .capital(of: "argentine"))
    }

    func test_interpretsISOCodeQuestion() async {
        let sut = makeSUT()

        let query = await sut.interpret("What is the ISO alpha-2 country code for Greece?")

        XCTAssertEqual(query, .isoCode(of: "Greece"))
    }

    func test_interpretsFlagQuestion() async {
        let sut = makeSUT()

        let query = await sut.interpret("Show me the flag of Brazil")

        XCTAssertEqual(query, .flag(of: "Brazil"))
    }

    func test_interpretsCountriesStartingWithQuestion() async {
        let sut = makeSUT()

        let query = await sut.interpret("Which countries start with CH?")

        XCTAssertEqual(query, .countriesStartingWith(prefix: "CH"))
    }

    func test_returnsUnknownForUnsupportedQuestion() async {
        let sut = makeSUT()

        let query = await sut.interpret("How tall is Mount Everest?")

        XCTAssertEqual(query, .unknown("Unrecognized type of question"))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CountryQuestionInterpreter {
        let sut = CountryQuestionInterpreter()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
