//
//  MovieListPresenter.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

protocol MovieListPresenterProtocol {
    var numberOfMovies: Int { get }
    func movie(at indexPath: IndexPath) -> MovieCellViewData
}

class MovieListPresenter {
    weak var view: MovieListViewProtocol?

    init(view: MovieListViewProtocol) {
        self.view = view
    }
}

extension MovieListPresenter: MovieListPresenterProtocol {
    var numberOfMovies: Int {
        return 10
    }

    func movie(at indexPath: IndexPath) -> MovieCellViewData {
        return MovieCellViewData(thumbnailURL: "", title: "Test movie", genres: [], popularityScore: 0.0, releaseYear: "")
    }
}
