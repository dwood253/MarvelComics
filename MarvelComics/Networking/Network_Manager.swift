//
//  API_Calls.swift
//  MarvelComics
//
//  Created by Daniel on 7/6/22.
//

import Foundation
import UIKit
import CryptoKit

fileprivate let TIMESTAMP = "ts"
fileprivate let KEY = "apikey"
fileprivate let HASH = "hash"

class NetworkManager {
    static let shared = NetworkManager()
    private let jsonDecoder = JSONDecoder()
    private var imageStore: [String: UIImage] = [:]
    private var keys: ApiKeys?
    
    init() {
        keys = ApiKeyHelper.getApiKeys()
    }
    
    func fetchRootComicData() async throws -> ComicDataWrapper {
        guard let url = try rootComicDataURL() else { throw FetchError.badUrl }
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badStatus }
        do {
            let comicData = try jsonDecoder.decode(ComicDataWrapper.self, from: data)
            return comicData
        } catch (let error) {
            //Log this error?
            print(error.localizedDescription)
        }
        throw FetchError.badData
    }
    
    func fetchImage(for path: String, doctype: String) async throws -> UIImage {
        if let image = imageStore[path] {
            return image
        } else {
            let url = URL(string: path + API.undocumented_required_image_name + "." + doctype)//getting 403 unless appending this image name to every call.
            let request = URLRequest(url: url!)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badStatus}
            let maybeImage = UIImage(data: data)
            guard let image = maybeImage else { throw FetchError.badImage }
            imageStore[path] = image
            return image
        }
    }
    
    private func rootComicDataURL() throws -> URL? {
        guard var components = URLComponents(string:API.BASE_URL + API.COMICS) else { return nil }
        let queryItems: [URLQueryItem] = try getApiKeyQueryItems()
        components.queryItems = queryItems
        return components.url
    }
    
    private func getApiKeyQueryItems() throws -> [URLQueryItem] {
        guard let keys = self.keys else { throw FetchError.missingAPIKeys }
        let timeStamp = Date().currentTimeMillisString()
        let hashed = MD5(string: timeStamp + keys.privateKey + keys.publicKey)
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: TIMESTAMP, value: timeStamp))
        queryItems.append(URLQueryItem(name: KEY, value: keys.publicKey))
        queryItems.append(URLQueryItem(name: HASH, value: hashed))
        return queryItems
    }
    
    private func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

enum FetchError: Error {
    case badStatus
    case badImage
    case badData
    case badUrl
    case missingAPIKeys
}


extension Date {
    func currentTimeMillisString() -> String {
        return String(Int64(self.timeIntervalSince1970 * 1000))
    }
}


