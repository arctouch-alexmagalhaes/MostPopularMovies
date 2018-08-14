//
//  MovieListPresenter.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import UIKit

protocol MovieListPresenterProtocol {
    var numberOfMovies: Int { get }

    func viewDidLoad()
    func movie(at indexPath: IndexPath) -> MovieCellViewData?
    func movieThumbnail(_ url: String?, completion: ((UIImage?) -> Void)?)
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

        let genre = movie.genres?.joined(separator: ", ")

        var releaseYear: String?
        if let releaseDate = movie.releaseDate {
            releaseYear = String(Calendar.current.component(.year, from: releaseDate))
        }
        return MovieCellViewData(thumbnailURL: movie.posterImagePath,
                                 title: movie.title,
                                 genres: genre,
                                 popularityScore: movie.popularity,
                                 releaseYear: releaseYear)
    }

    func movieThumbnail(_ url: String?, completion: ((UIImage?) -> Void)?) {
        repository.loadMovieThumbnail(url) { data in
            guard let data = data else {
                completion?(nil)
                return
            }
            completion?(UIImage(data: data))
        }
    }
}

extension MovieListPresenter: MoviesRepositoryDelegate {
    func moviesRepositoryDidUpdateListOfMovies(_ moviesRepository: MoviesRepositoryProtocol) {
        view?.dataIsReady()
    }
}
