import Foundation

public struct FanArtMovie: Codable {
    let name, tmdbID, imdbID: String?
    let hdmovielogo: [Hdmovieclearart]?
    let moviedisc: [Moviedisc]?
    let movielogo, movieposter, hdmovieclearart, movieart: [Hdmovieclearart]?
    let moviebackground, moviebanner, moviethumb: [Hdmovieclearart]?

    enum CodingKeys: String, CodingKey {
        case name
        case tmdbID
        case imdbID
        case hdmovielogo, moviedisc, movielogo, movieposter, hdmovieclearart, movieart, moviebackground, moviebanner, moviethumb
    }
}

// MARK: - Hdmovieclearart
struct Hdmovieclearart: Codable {
    let id: String?
    let url: String?
    let lang, likes: String?
}

// MARK: - Moviedisc
struct Moviedisc: Codable {
    let id: String?
    let url: String?
    let lang, likes, disc, discType: String?

    enum CodingKeys: String, CodingKey {
        case id, url, lang, likes, disc
        case discType
    }
}
