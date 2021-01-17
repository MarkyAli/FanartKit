import Foundation


// MARK: - FanArtTVShow
public struct FanArtTVShow: Codable {
    let name, thetvdbID: String?
    let clearlogo, hdtvlogo, clearart, showbackground: [Characterart]?
    let tvthumb, seasonposter, seasonthumb, hdclearart: [Characterart]?
    let tvbanner, characterart, tvposter, seasonbanner: [Characterart]?

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
