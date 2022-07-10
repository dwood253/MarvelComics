//
//  API_Strings.swift
//  MarvelComics
//
//  Created by Daniel on 7/6/22.
//

import Foundation

class API {
    //MARK: - Base api strings
    static let BASE_URL = "http://gateway.marvel.com/v1/public/"

    //MARK: - Comics
    static let COMICS = "comics"

    //needs to be appended to thumbnail urls for them to work otherwise get 403
    static let undocumented_required_image_name = "/portrait_uncanny" // + .extension
}



