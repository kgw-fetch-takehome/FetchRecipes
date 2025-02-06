//
//  FRImageLoader.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import Foundation
import UIKit

private let cache = NSCache<NSURL, UIImage>()

actor FRImageLoader {
    
    static var shared: FRImageLoader = FRImageLoader()
    
    private struct ImageData : Codable {
        var filename: String
        var lastAccessed: Date
    }

    private var cacheMap: [URL: ImageData]?

    private init() {
        // Load map from disk
    }
    
    func loadImage(from url: URL) async throws -> UIImage? {
        return try await loadImageAndSpecifyCached(from: url).image
    }
    
    func loadImageAndSpecifyCached(from url: URL) async throws -> (image:UIImage?, wasCached:Bool) {
        ensureMapLoaded()
        if let cachedData = cacheMap?[url] {
            if let image = fetchImageFromDisk(filename: cachedData.filename) {
                return (image, true)
            } else {
                // Not able to load from disk - remove from map
                cacheMap?[url] = nil
            }
        }
        
        // Fetch image over network
        let (data, _) = try await URLSession.shared.data(from: url)

        if let image = UIImage(data: data) {
            let filename = "\(UUID().uuidString).jpg"
            do {
                try writeImageToDisk(filename: filename, data: data)
                cacheMap?[url] = ImageData(filename: filename, lastAccessed: Date())
            }
            catch {
                // error writing image - don't add to cache map
                print("error writing image to disk \(error)")
            }
            return (image, false)
        }
        
        return (nil, false)
    }
    
    func deleteCacheMap() {
        self.cacheMap = nil
        try? FileManager.default.removeItem(at: cacheURL)
    }
    
    private let cacheURL = {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        let cacheDirURL = cacheDirectoryPath.appendingPathComponent("image-cache")
        return cacheDirURL
    }()

    private func ensureCacheDirectoryExists() {
        do {
            try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        }
        catch {
            print("error creating image cache directory \(error)")
            print("no image caching will be done")
        }
    }
    private func ensureMapLoaded() {
        ensureCacheDirectoryExists()
        guard cacheMap == nil else { return }
        if let data = try? Data(contentsOf: cacheURL),
            let decoded = try? JSONDecoder().decode([URL: ImageData].self, from: data) {
            cacheMap = decoded
        } else {
            cacheMap = [:]
        }
    }
    
    private func saveMapToDisk() {
        guard let cacheMap else { return }
        if let encoded = try? JSONEncoder().encode(cacheMap) {
            try? encoded.write(to: cacheURL, options: .atomic)
        }
    }
    
    private func fetchImageFromDisk(filename: String) -> UIImage? {
        let path = cacheURL.appendingPathComponent(filename).path
        return UIImage(contentsOfFile: path)
    }
    
    private func writeImageToDisk(filename: String, data: Data) throws {
        let path = cacheURL.appendingPathComponent(filename).path
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
}
