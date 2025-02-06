//
//  FRRecipesServiceTests.swift
//  FRRecipesServiceTests
//
//  Created by Kenneth Worley on 2/5/25.
//

import XCTest
@testable import FetchRecipes

final class FRRecipesServiceTests: XCTestCase {
    
    let kFetchEmptyRecipesFeedURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    let kFetchMalformedRecipesFeedURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchRecipes() async throws {
        
        let goodRecipes = try await FRRecipesService.fetchRecipes()
        XCTAssert(!goodRecipes.isEmpty, "no recipes returned")
        
        // Confirm all expected data present
        let numRecipes = goodRecipes.count
        var count = goodRecipes.reduce(0) { $0 + ($1.cuisine.isEmpty ? 0 : 1) }
        XCTAssertEqual(count, numRecipes, "missing cuisine values")
        count = goodRecipes.reduce(0) { $0 + ($1.name.isEmpty ? 0 : 1) }
        XCTAssertEqual(count, numRecipes, "missing name values")
        count = goodRecipes.reduce(0) { $0 + ($1.largePhotoURL==nil ? 0 : 1) }
        XCTAssertEqual(count, numRecipes, "missing large photo URL values")
        count = goodRecipes.reduce(0) { $0 + ($1.smallPhotoURL==nil ? 0 : 1) }
        XCTAssertEqual(count, numRecipes, "missing small photo URL values")
        count = goodRecipes.reduce(0) { $0 + ($1.uuid.isEmpty ? 0 : 1) }
        XCTAssertEqual(count, numRecipes, "missing UUID values")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testFetchEmptyRecipes() async throws {
        let emptyRecipes = try await FRRecipesService.fetchRecipes(recipesURL: kFetchEmptyRecipesFeedURL)
        XCTAssert(emptyRecipes.isEmpty, "expected empty recipes array")
    }
    
    func testFetchMalformedRecipes() async throws {
        do {
            _ = try await FRRecipesService.fetchRecipes(recipesURL: kFetchMalformedRecipesFeedURL)
            XCTFail("fetching malformed recipes should throw error")
        }
        catch {
            // Expected error here
        }
    }
}
