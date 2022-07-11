//
//  MarvelComicsTests.swift
//  MarvelComicsTests
//
//  Created by Daniel on 7/6/22.
//

import XCTest
@testable import MarvelComics

class MarvelComicsTests: XCTestCase {
    
    /// This tests whether there are valid api keys available and comic data can be fetched from the api
    func testAssertNotNilWhenValidAPIKeys() async throws {
        let comicInfo = try await NetworkManager.shared.fetchRootComicData()
        XCTAssertNotNil(comicInfo)
    }
    
    /// This tests that an error is thrown when API keys are missing
    func testErrorThrowingWhenMissingAPIKeys() async throws {
        do {
            NetworkManager.shared.disposeOfKeys()
            _ = try await NetworkManager.shared.fetchRootComicData()
        } catch let error {
            XCTAssertEqual(error as? FetchError, FetchError.missingAPIKeys)
        }
    }

}
