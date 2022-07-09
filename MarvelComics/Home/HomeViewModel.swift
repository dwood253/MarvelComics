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
    lazy var modelError = PassthroughSubject<String, Never>()
    
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
//
//    func getComicImage(image: Image?) async throws -> UIImage? {
////        guard let path = image?.path, let imageExtension = image?.image_extension else { return nil }
////        Task { () -> UIImage? in
////            do {
////                let image = try await NetworkManager.shared.fetchImage(for: path, doctype: imageExtension)
////                return image
////            } catch let error {
////                print(error.localizedDescription)
////                //TODO: log this error to crashlytics
////                return nil
////            }
////        }
//
//        guard let path = image?.path, let imageExtension = image?.image_extension else { return nil }
//        let image = try await NetworkManager.shared.fetchImage(for: path, doctype: imageExtension)
//    }
}
