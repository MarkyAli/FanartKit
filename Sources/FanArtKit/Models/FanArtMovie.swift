import Foundation

public struct FanArtMovie: Codable {
    public let name, tmdbID, imdbID: String?
    public let hdmovielogo: [Hdmovieclearart]?
    public let moviedisc: [Moviedisc]?
    public let movielogo, movieposter, hdmovieclearart, movieart: [Hdmovieclearart]?
    public let moviebackground, moviebanner, moviethumb: [Hdmovieclearart]?

    enum CodingKeys: String, CodingKey {
        case name
        case tmdbID
        case imdbID
        case hdmovielogo, moviedisc, movielogo, movieposter, hdmovieclearart, movieart, moviebackground, moviebanner, moviethumb
    }
}

// MARK: - Hdmovieclearart
public struct Hdmovieclearart: Codable {
    public let id: String?
    public let url: String?
    public let lang, likes: String?
}

// MARK: - Moviedisc
public struct Moviedisc: Codable {
    public let id: String?
    public let url: String?
    public let lang, likes, disc, discType: String?

    enum CodingKeys: String, CodingKey {
        case id, url, lang, likes, disc
        case discType
    }
}
