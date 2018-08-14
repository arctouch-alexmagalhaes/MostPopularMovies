//
//  ServiceConstants.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/13/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

enum ServiceConstants {
    static private let baseURL = "https://api.themoviedb.org/3"
    static private let baseImageURL = "https://image.tmdb.org/t/p"

    static let apiKey = "8badbf7ae17577baae23966eefdd29f8"
    static let moviesURL = "\(baseURL)/movie/popular"
    static let genresURL = "\(baseURL)/genre/movie/list"

    static func thumbnailImageURL(relativeURL: String, desiredWidth: Int) -> String {
        return "\(baseImageURL)/w\(desiredWidth)\(relativeURL)"
    }
}
