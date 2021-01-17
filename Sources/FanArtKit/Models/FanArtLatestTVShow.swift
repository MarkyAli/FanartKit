import Foundation

public struct FanArtLatestTVShow: Codable {
    public let id, name, newImages, totalImages: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case newImages
        case totalImages
    }
}

public typealias FanArtLatestTVShows = [FanArtLatestTVShow]
public typealias FanArtLatestMusic = [FanArtLatestTVShow]
