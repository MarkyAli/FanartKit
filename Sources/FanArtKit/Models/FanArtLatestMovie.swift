import Foundation

public struct FanArtLatestMovie: Codable {
    public let tmdbID, imdbID, name, newImages: String?
    public let totalImages: String?

    enum CodingKeys: String, CodingKey {
        case tmdbID
        case imdbID
        case name
        case newImages
        case totalImages
    }
}

public typealias FanArtLatestMovies = [FanArtLatestMovie]
