//
//  FRImageLoaderTests.swift
//  FRImageLoaderTests
//
//  Created by Kenneth Worley on 2/5/25.
//

import XCTest
@testable import FetchRecipes

final class FRImageLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImageLoader() async throws {
        
        let goodImages = [
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/54462bd7-afc2-43aa-a10e-3ddd0a829954/small.jpg",
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/27c50c00-148e-4d2a-abb7-942182bb6d94/small.jpg",
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/1c1616f6-81d2-447d-a1ae-51352edfde0c/small.jpg"
        ]
        
        let badImages = [
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/54462bd7-afc2-43aa-a10e-3ddd0a829954/nonexistent.jpg",
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/27c50c00-148e-4d2a-abb7-942182bb6d94/nonexistent.jpg",
            "https://d3jbb8n5wk0qxi.cloudfront.net/photos/1c1616f6-81d2-447d-a1ae-51352edfde0c/nonexistent.jpg"
        ]
        
        await FRImageLoader.shared.deleteCacheMap()

        for imageUrl in goodImages {
            let image = try await FRImageLoader.shared.loadImage(from: URL(string: imageUrl)!)
            XCTAssertNotNil(image, "image is nil")
        }
        
        for imageUrl in badImages {
            let image = try await FRImageLoader.shared.loadImage(from: URL(string: imageUrl)!)
            XCTAssertNil(image, "image should be nil")
        }
        
        // Test caching
        
        await FRImageLoader.shared.deleteCacheMap()
        
        for imageUrl in goodImages {
            let (image, cached) = try await FRImageLoader.shared.loadImageAndSpecifyCached(from: URL(string: imageUrl)!)
            XCTAssertNotNil(image, "image is nil")
            XCTAssertFalse(cached, "image should not be cached first time")
        }

        for imageUrl in goodImages {
            let (image, cached) = try await FRImageLoader.shared.loadImageAndSpecifyCached(from: URL(string: imageUrl)!)
            XCTAssertNotNil(image, "image is nil")
            XCTAssertTrue(cached, "image should be cached second time")
        }
    }
}
