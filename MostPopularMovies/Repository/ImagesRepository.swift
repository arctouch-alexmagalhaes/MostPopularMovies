//
//  ImagesRepository.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/16/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import UIKit

protocol ImagesRepositoryProtocol: class {
    func loadConfiguration(completion: (() -> Void)?)
    func loadBackdropImage(_ relativeURL: String?, width: Int, completion: ((Data?) -> Void)?)
    func loadPosterImage(_ relativeURL: String?, width: Int, completion: ((Data?) -> Void)?)
}

class ImagesRepository {
    static let shared: ImagesRepositoryProtocol = ImagesRepository()

    private let imageService: ImageServiceProtocol = ImageService()
    private let contentService: ContentServiceProtocol = ContentService()
    private var configuration: Configuration?

    private func loadImage(_ relativeURL: String?, width: Int, availableWidths: [String],
                           completion: ((Data?) -> Void)?) {
        guard let baseImageURL = configuration?.baseImageURL, let relativeURL = relativeURL else {
            completion?(nil)
            return
        }

        let scaledWidth = Int(CGFloat(width) * UIScreen.main.scale)
        let idealWidth = availableWidths.first { widthString -> Bool in
            let onlyDigits = widthString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let availableWidth = Int(onlyDigits) ?? 0
            return scaledWidth < availableWidth
        } ?? "original"

        let url = "\(baseImageURL)\(idealWidth)\(relativeURL)"
        imageService.requestImage(url, completion: completion)
    }
}

extension ImagesRepository: ImagesRepositoryProtocol {
    func loadConfiguration(completion: (() -> Void)?) {
        contentService.request(.configuration) { [weak self] (configurationDictionary, error) in
            if let error = error {
                print("Error while requesting configuration: \(error.localizedDescription)")
            }

            let imagesDictionary = configurationDictionary?["images"] as? [String: Any]

            let baseImageURL = imagesDictionary?["secure_base_url"] as? String
            let backdropSizes = imagesDictionary?["backdrop_sizes"] as? [String]
            let posterSizes = imagesDictionary?["poster_sizes"] as? [String]

            self?.configuration = Configuration(baseImageURL: baseImageURL,
                                                backdropSizes: backdropSizes,
                                                posterSizes: posterSizes)

            completion?()
        }
    }

    func loadBackdropImage(_ relativeURL: String?, width: Int, completion: ((Data?) -> Void)?) {
        guard let sizes = configuration?.backdropSizes else {
            completion?(nil)
            return
        }
        loadImage(relativeURL, width: width, availableWidths: sizes, completion: completion)
    }

    func loadPosterImage(_ relativeURL: String?, width: Int, completion: ((Data?) -> Void)?) {
        guard let sizes = configuration?.posterSizes else {
            completion?(nil)
            return
        }
        loadImage(relativeURL, width: width, availableWidths: sizes, completion: completion)
    }
}
