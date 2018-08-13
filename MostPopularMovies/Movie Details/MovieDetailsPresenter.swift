//
//  MovieDetailsPresenter.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

protocol MovieDetailsPresenterProtocol: class {
    func movieDetails(at indexPath: IndexPath) -> MovieDetailsViewData
}

class MovieDetailsPresenter {
    weak var view: MovieDetailsViewProtocol?

    init(view: MovieDetailsViewProtocol) {
        self.view = view
    }
}

extension MovieDetailsPresenter: MovieDetailsPresenterProtocol {
    func movieDetails(at indexPath: IndexPath) -> MovieDetailsViewData {
        return MovieDetailsViewData(thumbnailURL: "", title: "Test movie", genres: [], popularityScore: 0.0, releaseYear: "", description: "", runtime: 0, revenue: 0, language: "", websiteLink: "")
    }
}
