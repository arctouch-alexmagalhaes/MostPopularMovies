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

    func viewDidLoad()
    func movie(at indexPath: IndexPath) -> MovieCellViewData?
}

class MovieListPresenter {
    private weak var view: MovieListViewProtocol?
    private let repository: MoviesRepositoryProtocol = MoviesRepository.shared

    var numberOfMovies: Int {
        return repository.loadedMovies.count
    }

    init(view: MovieListViewProtocol) {
        self.view = view
    }
}

extension MovieListPresenter: MovieListPresenterProtocol {
    func viewDidLoad() {
        repository.loadMoreMovies { [weak self] in
            self?.view?.dataIsReady()
        }
    }

    func movie(at indexPath: IndexPath) -> MovieCellViewData? {
        guard indexPath.row < repository.loadedMovies.count else { return nil }
        let movie = repository.loadedMovies[indexPath.row]

        var releaseYear: String?
        if let releaseDate = movie.releaseDate {
            releaseYear = String(Calendar.current.component(.year, from: releaseDate))
        }
        return MovieCellViewData(thumbnailURL: movie.posterImagePath,
                                 title: movie.title,
                                 genres: movie.genres,
                                 popularityScore: movie.popularity,
                                 releaseYear: releaseYear)
    }
}
