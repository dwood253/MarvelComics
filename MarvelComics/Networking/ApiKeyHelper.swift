//
//  TokenHelper.swift
//  MarvelComics
//
//  Created by Daniel on 7/8/22.
//

import Foundation
fileprivate let API_FILENAME = "marvel_api_keys"

class ApiKeyHelper {
    static func getApiKeys() -> ApiKeys? {
        do {
            if let path = Bundle.main.path(forResource: API_FILENAME, ofType: "json") {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url)
                let keys = try JSONDecoder().decode(ApiKeys.self, from: data)
                return keys
            } else {
                return nil
            }
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

struct ApiKeys: Codable {
    let privateKey: String
    let publicKey: String
}
