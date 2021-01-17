import Foundation


// MARK: - FanArtTVShow
public struct FanArtTVShow: Codable {
    public let name, thetvdbID: String?
    public let clearlogo, hdtvlogo, clearart, showbackground: [Characterart]?
    public let tvthumb, seasonposter, seasonthumb, hdclearart: [Characterart]?
    public let tvbanner, characterart, tvposter, seasonbanner: [Characterart]?

    enum CodingKeys: String, CodingKey {
        case name
        case thetvdbID
        case clearlogo, hdtvlogo, clearart, showbackground, tvthumb, seasonposter, seasonthumb, hdclearart, tvbanner, characterart, tvposter, seasonbanner
    }
}

// MARK: - Characterart
public struct Characterart: Codable {
    let id: String?
    let url: String?
    let lang: String?
    let likes: String?
    let season: String?
}
