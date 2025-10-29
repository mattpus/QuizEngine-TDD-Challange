import XCTest
@testable import QuizEngineCore

@MainActor
final class RemoteCountryLoaderTests: XCTestCase {
    func test_load_requestsDataFromURL() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        client.stub(result: .success((Data("[]".utf8), anyHTTPResponse(statusCode: 200))))
        _ = try await sut.loadCountries()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        client.stub(result: .failure(error))

        do {
            _ = try await sut.loadCountries()
            XCTFail("Expected error")
        } catch {
            guard case RemoteCountryLoader.Error.connectivity = error else {
                return XCTFail("Expected connectivity error")
            }
        }
    }

    func test_load_deliversErrorOnNon200Response() async {
        let samples = [199, 201, 300, 400, 500]

        for statusCode in samples {
            let (sut, client) = makeSUT()
            client.stub(result: .success((anyData(), anyHTTPResponse(statusCode: statusCode))))

            do {
                _ = try await sut.loadCountries()
                XCTFail("Expected invalidData error for status code \(statusCode)")
            } catch {
                guard case RemoteCountryLoader.Error.invalidData = error else {
                    return XCTFail("Expected invalidData error")
                }
            }
        }
    }

    func test_load_deliversErrorOn200ResponseWithInvalidData() async {
        let (sut, client) = makeSUT()
        client.stub(result: .success((Data("invalid".utf8), anyHTTPResponse(statusCode: 200))))

        do {
            _ = try await sut.loadCountries()
            XCTFail("Expected invalidData error")
        } catch {
            guard case RemoteCountryLoader.Error.invalidData = error else {
                return XCTFail("Expected invalidData error")
            }
        }
    }

    func test_load_deliversCountriesOn200ResponseWithValidData() async throws {
        let (sut, client) = makeSUT()
        let countries = [
            Country(name: "Belgium", capitalCities: ["Brussels"], isoCode: "BE", flagEmoji: "🇧🇪", flagImageURL: URL(string: "https://flag.com/be.png")),
            Country(name: "Argentina", capitalCities: ["Buenos Aires"], isoCode: "AR", flagEmoji: "🇦🇷", flagImageURL: URL(string: "https://flag.com/ar.png"))
        ]
        client.stub(result: .success((makeCountriesData(from: countries), anyHTTPResponse(statusCode: 200))))

        let received = try await sut.loadCountries()

        XCTAssertEqual(received, countries)
    }

    func test_load_deliversCountriesOn200ResponseWithMissingOptionalFields() async throws {
        let (sut, client) = makeSUT()
        let countries = [
            Country(name: "No Capital", capitalCities: [], isoCode: "NC", flagEmoji: nil, flagImageURL: nil)
        ]
        client.stub(result: .success((makeCountriesData(from: countries), anyHTTPResponse(statusCode: 200))))

        let received = try await sut.loadCountries()

        XCTAssertEqual(received, countries)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://restcountries.com/v3.1/all")!, file: StaticString = #file, line: UInt = #line) -> (RemoteCountryLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCountryLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func makeCountriesData(from countries: [Country]) -> Data {
        let dto = countries.map {
            [
                "name": ["common": $0.name],
                "capital": $0.capitalCities,
                "cca2": $0.isoCode,
                "flag": $0.flagEmoji as Any,
                "flags": ["png": $0.flagImageURL?.absoluteString as Any]
            ] as [String: Any]
        }
        return try! JSONSerialization.data(withJSONObject: dto)
    }
}
