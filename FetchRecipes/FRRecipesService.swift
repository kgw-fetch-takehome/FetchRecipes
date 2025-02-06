//
//  FRRecipesService.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import Foundation

let kFetchRecipesFeedURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")

struct FRRecipeFeed : Codable {
    private(set) var recipes: [FRRecipe]
}

final class FRRecipesService {
    
    static func fetchRecipes() async throws -> [FRRecipe] {
        guard let kFetchRecipesFeedURL else {
            throw NSError(domain: "FetchRecipes", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"])
        }
        
//        // testing code
//        let messUp = Bool.random()
//        if messUp {
//            try? await Task.sleep(nanoseconds: UInt64(1.5 * Double(NSEC_PER_SEC)))
//            return try await fetchRecipes(recipesURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!)
//            return try await fetchRecipes(recipesURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!)
//        }
        
        return try await fetchRecipes(recipesURL: kFetchRecipesFeedURL)
    }
    
    static func fetchRecipes(recipesURL: URL) async throws -> [FRRecipe] {
        let startedAt = Date()
        let desiredMinLatency: TimeInterval = 1.5
        let request = URLRequest(url: recipesURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        let feed = try JSONDecoder().decode(FRRecipeFeed.self, from: data)
        let elapsed = Date().timeIntervalSince(startedAt)
        if elapsed < desiredMinLatency {
            try? await Task.sleep(nanoseconds: UInt64((desiredMinLatency - elapsed) * Double(NSEC_PER_SEC)))
        }
        return feed.recipes
    }
}
