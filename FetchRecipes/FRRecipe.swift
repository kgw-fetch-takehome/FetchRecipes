//
//  FRRecipe.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import Foundation

struct FRRecipe : Codable {
    private(set) var cuisine: String
    private(set) var name: String
    private      var photoUrlLarge: String
    private      var photoUrlSmall: String
    private      var sourceUrl: String?
    private(set) var uuid: String
    private      var youtubeUrl: String?
    
    enum CodingKeys : String, CodingKey {
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case uuid
        case youtubeUrl = "youtube_url"
    }
    
    var smallPhotoURL: URL? {
        URL(string: photoUrlSmall)
    }
    
    var largePhotoURL: URL? {
        URL(string: photoUrlLarge)
    }
    
    var sourceURL: URL? {
        guard let sourceUrl else { return nil }
        return URL(string: sourceUrl)
    }
    
    var videoURL: URL? {
        guard let youtubeUrl else { return nil }
        return URL(string: youtubeUrl)
    }
    
    static func mock() -> FRRecipe {
        let randElem = Int((0..<3).randomElement()!)
        let cuisines = ["Italian", "American", "Mexican"]
        let names = ["Spaghetti Carbonara", "Chicken Fajitas", "Beef Wellington"]
        let urls = [
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/",
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b2879d3a-b145-4618-9c1d-fd3a451d0739/",
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/3b33a385-3e55-4ea5-9d98-13e78f840299/"
        ]
        return .init(
            cuisine: cuisines[randElem],
            name: names[randElem],
            photoUrlLarge: "\(urls[randElem])large.jpg",
            photoUrlSmall: "\(urls[randElem])small.jpg",
            sourceUrl: "https://www.apple.com",
            uuid: UUID().uuidString,
            youtubeUrl: "https://www.youtube.com"
        )
    }
}

extension FRRecipe : Identifiable {
    var id: String {
        uuid
    }
}
