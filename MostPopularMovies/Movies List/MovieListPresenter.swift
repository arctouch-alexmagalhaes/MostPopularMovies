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
    func movieThumbnail(_ url: String?, width: CGFloat, completion: ((UIImage?) -> Void)?)
}

class MovieListPresenter {
    private weak var view: MovieListViewProtocol?
    private let moviesRepository: MoviesRepositoryProtocol = MoviesRepository.shared
    private let imagesRepository: ImagesRepositoryProtocol = ImagesRepository.shared

    var numberOfMovies: Int {
        return moviesRepository.numberOfMovies
    }

    init(view: MovieListViewProtocol) {
        self.view = view
        moviesRepository.delegate = self
    }
}

extension MovieListPresenter: MovieListPresenterProtocol {
    func viewDidLoad() {
        imagesRepository.loadConfiguration { [weak self] in
            self?.moviesRepository.loadMovies()
        }
    }

    func movie(at indexPath: IndexPath) -> MovieCellViewData? {
        guard indexPath.row < moviesRepository.numberOfMovies else { return nil }
        let movie = moviesRepository.movie(at: indexPath.row)

        let genre = movie.genres?.joined(separator: ", ")

        var releaseYear: String?
        if let releaseDate = movie.releaseDate {
            releaseYear = "(\(Calendar.current.component(.year, from: releaseDate)))"
        }
        return MovieCellViewData(thumbnailURL: movie.posterImagePath,
                                 title: movie.title,
                                 genres: genre,
                                 popularityScore: movie.popularity,
                                 releaseYear: releaseYear)
    }

    func movieThumbnail(_ url: String?, width: CGFloat, completion: ((UIImage?) -> Void)?) {
        imagesRepository.loadPosterImage(url, width: Int(width)) { data in
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
