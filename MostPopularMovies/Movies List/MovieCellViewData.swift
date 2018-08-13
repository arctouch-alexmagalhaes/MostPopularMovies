//
//  MovieCellViewData.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

struct MovieCellViewData {
    let thumbnailURL: String
    let title: String
    let genres: [String]
    let popularityScore: Double
    let releaseYear: String
}
