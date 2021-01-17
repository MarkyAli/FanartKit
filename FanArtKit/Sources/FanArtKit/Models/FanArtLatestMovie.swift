import Foundation

public struct FanArtLatestMovie: Codable {
    let tmdbID, imdbID, name, newImages: String?
    let totalImages: String?

    enum CodingKeys: String, CodingKey {
        case tmdbID
        case imdbID
        case name
        case newImages
        case totalImages
    }
}

public typealias FanArtLatestMovies = [FanArtLatestMovie]
