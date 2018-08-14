//
//  Movie.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

struct Movie {
    let id: Int?
    let title: String?
    let tagline: String?
    let genres: [String]?
    let description: String?
    let originalTitle: String?
    let originalLanguageCode: String?
    let releaseDate: Date?
    let runtimeInMinutes: Int?
    let budget: Int?
    let revenue: Int?
    let popularity: Double?
    let voteAverage: Double?
    let voteCount: Int?
    let status: String?
    let posterImagePath: String?
    let backdropImagePath: String?
    let websitePath: String?
    let isAdult: Bool?
}
