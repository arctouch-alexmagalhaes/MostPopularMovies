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
        return repository.numberOfMovies
    }

    init(view: MovieListViewProtocol) {
        self.view = view
        repository.delegate = self
    }
}

extension MovieListPresenter: MovieListPresenterProtocol {
    func viewDidLoad() {
        repository.loadMovies()
    }

    func movie(at indexPath: IndexPath) -> MovieCellViewData? {
        guard indexPath.row < repository.numberOfMovies else { return nil }
        let movie = repository.movie(at: indexPath.row)

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

extension MovieListPresenter: MoviesRepositoryDelegate {
    func moviesRepositoryDidUpdateListOfMovies(_ moviesRepository: MoviesRepositoryProtocol) {
        view?.dataIsReady()
    }
}
