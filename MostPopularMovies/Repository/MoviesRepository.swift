//
//  MoviesRepository.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/13/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

protocol MoviesRepositoryDelegate: class {
    func moviesRepositoryDidUpdateListOfMovies(_ moviesRepository: MoviesRepositoryProtocol)
}

protocol MoviesRepositoryProtocol: class {
    var delegate: MoviesRepositoryDelegate? { get set }
    var numberOfMovies: Int { get }

    func movie(at index: Int) -> Movie
    func loadMovies()
}

class MoviesRepository {
    static let shared: MoviesRepositoryProtocol = MoviesRepository()

    private let contentService: ContentServiceProtocol = ContentService()
    private var totalNumberOfMovies: Int = 0
    private var totalNumberOfPages: Int = 0
    private var lastLoadedPage: Int = 0
    private var loadedMovies: [Movie] = []
    private var isLoadingGenres: Bool = false
    private var isLoadingMovies: Bool = false
    private var genres: [Genre]? = nil
    weak var delegate: MoviesRepositoryDelegate?

    private func loadGenres(completion: @escaping () -> Void) {
        guard !isLoadingGenres else { return }
        isLoadingGenres = true
        contentService.request(.movieGenres) { [weak self] (genresDictionary, error) in
            if error != nil {
                //TODO handle error
            }

            let genresArray = genresDictionary?["genres"] as? [[String: Any]]
            let genres = genresArray?.compactMap({ genreDictionary -> Genre? in
                guard let id = genreDictionary["id"] as? Int,
                    let name = genreDictionary["name"] as? String else { return nil }
                return Genre(id: id, name: name)
            })

            self?.genres = genres ?? [] // genres is no longer nil after this point
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingGenres = false
                completion()
            }
        }
    }

    private func parseMoviesDictionary(_ moviesDictionary: [AnyHashable: Any]?) {
        guard let moviesDictionary = moviesDictionary else { return }

        if let page = moviesDictionary["page"] as? Int {
            lastLoadedPage = page
        }

        if let totalResults = moviesDictionary["total_results"] as? Int {
            totalNumberOfMovies = totalResults
        }

        if let totalPages = moviesDictionary["total_pages"] as? Int {
            totalNumberOfPages = totalPages
        }

        if let results = moviesDictionary["results"] as? [[AnyHashable: Any]] {
            let newMovies = results.map { self.parseMovie($0) }
            loadedMovies.append(contentsOf: newMovies)
        }
    }

    private func parseMovie(_ movieDictionary: [AnyHashable: Any]) -> Movie {
        var genres: [String]?
        if let genreObjects = movieDictionary["genres"] as? [[AnyHashable: Any]] {
            genres = genreObjects.compactMap { $0["name"] as? String }
        } else if let genreIDs = movieDictionary["genre_ids"] as? [Int] {
            genres = self.genres?.compactMap({ genre -> String? in
                guard genreIDs.contains(genre.id) else { return nil }
                return genre.name
            })
        }

        var releaseDate: Date?
        if let dateString = movieDictionary["release_date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            releaseDate = dateFormatter.date(from: dateString)
        }

        return Movie(id: movieDictionary["id"] as? Int,
                     title: movieDictionary["title"] as? String,
                     tagline: movieDictionary["tagline"] as? String,
                     genres: genres,
                     description: movieDictionary["overview"] as? String,
                     originalTitle: movieDictionary["original_title"] as? String,
                     originalLanguageCode: movieDictionary["original_language"] as? String,
                     releaseDate: releaseDate,
                     runtimeInMinutes: movieDictionary["runtime"] as? Int,
                     budget: movieDictionary["budget"] as? Int,
                     revenue: movieDictionary["revenue"] as? Int,
                     popularity: movieDictionary["popularity"] as? Double,
                     voteAverage: movieDictionary["vote_average"] as? Double,
                     voteCount: movieDictionary["vote_count"] as? Int,
                     status: movieDictionary["status"] as? String,
                     posterImagePath: movieDictionary["poster_path"] as? String,
                     backdropImagePath: movieDictionary["backdrop_path"] as? String,
                     websitePath: movieDictionary["homepage"] as? String,
                     isAdult: movieDictionary["adult"] as? Bool)
    }
}

extension MoviesRepository: MoviesRepositoryProtocol {
    var numberOfMovies: Int {
        return loadedMovies.count
    }

    func movie(at index: Int) -> Movie {
        if index + 10 > loadedMovies.count && index < totalNumberOfMovies {
            loadMovies()
        }

        return loadedMovies[index]
    }

    func loadMovies() {
        guard genres != nil else {
            loadGenres { [weak self] in
                self?.loadMovies()
            }
            return
        }

        let newPage = lastLoadedPage + 1
        guard newPage <= totalNumberOfPages || totalNumberOfPages == 0 else {
            return
        }

        guard !isLoadingMovies else { return }
        isLoadingMovies = true
        contentService.request(.popularMovies, page: newPage) { [weak self] (moviesDictionary, error) in
            if error != nil {
                //TODO handle error
            }

            self?.parseMoviesDictionary(moviesDictionary)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.isLoadingMovies = false
                strongSelf.delegate?.moviesRepositoryDidUpdateListOfMovies(strongSelf)
            }
        }
    }
}
