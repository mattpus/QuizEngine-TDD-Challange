import Foundation

public struct Country: Equatable {
    public let name: String
    public let capitalCities: [String]
    public let isoCode: String
    public let flagEmoji: String?
    public let flagImageURL: URL?

    public init(
        name: String,
        capitalCities: [String],
        isoCode: String,
        flagEmoji: String?,
        flagImageURL: URL?
    ) {
        self.name = name
        self.capitalCities = capitalCities
        self.isoCode = isoCode
        self.flagEmoji = flagEmoji
        self.flagImageURL = flagImageURL
    }
}
