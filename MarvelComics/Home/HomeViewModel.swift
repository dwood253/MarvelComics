//
//  HomeViewModel.swift
//  MarvelComics
//
//  Created by Daniel on 7/7/22.
//

import Foundation
import Combine
import UIKit

class HomeViewModel {
    lazy var comics = PassthroughSubject<[Comic], Error>()
    
    func getComics() {
        Task {
            do {
                let comicData = try await NetworkManager.shared.fetchRootComicData()
                guard let comicResults = comicData.data?.results else { return }
                comics.send(comicResults)
                comics.send(completion: .finished)
            } catch let error {
                comics.send(completion: .failure(error))
                //TODO: log this error to crashlytics
            }
        }
    }
}
