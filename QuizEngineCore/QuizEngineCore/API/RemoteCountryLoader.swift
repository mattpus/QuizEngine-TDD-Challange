import Foundation

public final class RemoteCountryLoader {
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }

    private let url: URL
    private let client: HTTPClient
    private let decoder: JSONDecoder

    public init(url: URL, client: HTTPClient, decoder: JSONDecoder = JSONDecoder()) {
        self.url = url
        self.client = client
        self.decoder = decoder
    }

    public func load() async throws -> [Country] {
        let payload: (data: Data, response: HTTPURLResponse)

        do {
            payload = try await client.get(from: url)
        } catch {
            throw Error.connectivity
        }

        guard payload.response.statusCode == 200 else {
            throw Error.invalidData
        }

        do {
            return try decoder.decode([CountryDTO].self, from: payload.data).map(\.model)
        } catch {
            throw Error.invalidData
        }
    }
}

private struct CountryDTO: Decodable {
    struct Name: Decodable {
        let common: String
    }

    struct Flags: Decodable {
        let png: String?
    }

    let name: Name
    let capital: [String]?
    let cca2: String
    let flag: String?
    let flags: Flags?

    var model: Country {
        Country(
            name: name.common,
            capitalCities: capital ?? [],
            isoCode: cca2,
            flagEmoji: flag,
            flagImageURL: flags?.png.flatMap(URL.init(string:))
        )
    }
}
