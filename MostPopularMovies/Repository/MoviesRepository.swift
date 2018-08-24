//
//  MoviesRepository.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/13/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

protocol MoviesRepositoryDelegate: class {
    func moviesRepositoryDidReloadListOfMovies(_ moviesRepository: MoviesRepositoryProtocol)
    func moviesRepositoryDidUpdateListOfMovies(_ moviesRepository: MoviesRepositoryProtocol)
    func moviesRepositoryDidFailLoadingMovies(_ moviesRepository: MoviesRepositoryProtocol)
}

protocol MoviesRepositoryProtocol: class {
    var delegate: MoviesRepositoryDelegate? { get set }
    var numberOfMovies: Int { get }

    func movie(at index: Int) -> Movie?
    func loadMovies()
    func refreshMovies()
    func searchForMovies(searchQuery: String)
    func loadMovieDetails(_ id: Int, completion: ((Movie?) -> Void)?)
}

class MoviesRepository {
    static let shared: MoviesRepositoryProtocol = MoviesRepository()

    private let contentService: ContentServiceProtocol = ContentService()

    private var totalNumberOfMovies: Int = 0
    private var totalNumberOfPages: Int = 0
    private var lastLoadedPage: Int = 0
    private var loadedMovies: [Movie] = []
    private var genres: [Genre]?

    private var isLoadingGenres: Bool = false
    private var isLoadingMovies: Bool = false

    private var currentSearchQuery: String = ""
    private var pendingSearchQuery: String?

    weak var delegate: MoviesRepositoryDelegate?

    private func loadGenres(completion: @escaping () -> Void) {
        guard !isLoadingGenres else { return }
        isLoadingGenres = true
        contentService.request(.movieGenres) { [weak self] (genresDictionary, error) in
            if let error = error {
                print("Error while requesting genres: \(error.localizedDescription)")
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

    private func performPendingSearchIfNeeded() {
        guard !isLoadingGenres, !isLoadingMovies, let searchQuery = pendingSearchQuery else { return }

        pendingSearchQuery = nil
        guard currentSearchQuery != searchQuery else { return }

        currentSearchQuery = searchQuery
        lastLoadedPage = 0
        totalNumberOfMovies = 0
        totalNumberOfPages = 0
        loadedMovies = []
        loadMovies()
    }

    private func handleMoviesResponse(requestedPage: Int, moviesDictionary: [AnyHashable: Any]?, error: Error?) {
        if let error = error {
            print("Error while requesting movies: \(error.localizedDescription)")
        }

        parseMoviesDictionary(moviesDictionary)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.isLoadingMovies = false

            if error != nil {
                strongSelf.delegate?.moviesRepositoryDidFailLoadingMovies(strongSelf)
            } else if requestedPage > 1 {
                strongSelf.delegate?.moviesRepositoryDidUpdateListOfMovies(strongSelf)
            } else {
                strongSelf.delegate?.moviesRepositoryDidReloadListOfMovies(strongSelf)
            }

            strongSelf.performPendingSearchIfNeeded()
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
            let newMovies = results.map { self.parseMovie(dictionary: $0) }
            loadedMovies.append(contentsOf: newMovies)
        }
        loadedMovies.sort { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
    }

    private func parseMovie(dictionary movieDictionary: [AnyHashable: Any]?, existingID: Int? = nil) -> Movie {
        var movie: Movie?
        if let movieIndex = loadedMovies.index(where: { $0.id == existingID }) {
            movie = loadedMovies[movieIndex]
        }

        let dictionary = movieDictionary ?? [:]
        let newMovie = createMovie(from: dictionary, existingMovie: movie)

        if let movieIndex = loadedMovies.index(where: { $0.id == existingID }) {
            loadedMovies[movieIndex] = newMovie
        }
        return newMovie
    }

    private func createMovie(from dictionary: [AnyHashable: Any],
                             existingMovie movie: Movie?) -> Movie {
        var genres: [String]?
        if let genreObjects = dictionary["genres"] as? [[AnyHashable: Any]] {
            genres = genreObjects.compactMap { $0["name"] as? String }
        } else if let genreIDs = dictionary["genre_ids"] as? [Int] {
            genres = self.genres?.compactMap({ genre -> String? in
                guard genreIDs.contains(genre.id) else { return nil }
                return genre.name
            })
        }

        var languages: [String]?
        if let languageObjects = dictionary["spoken_languages"] as? [[AnyHashable: Any]] {
            languages = languageObjects.compactMap { $0["name"] as? String }
        }

        var releaseDate: Date?
        if let dateString = dictionary["release_date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            releaseDate = dateFormatter.date(from: dateString)
        }

        return Movie(id: dictionary["id"] as? Int ?? movie?.id,
                     title: dictionary["title"] as? String ?? movie?.title,
                     tagline: dictionary["tagline"] as? String ?? movie?.tagline,
                     genres: genres ?? movie?.genres,
                     languages: languages ?? movie?.languages,
                     description: dictionary["overview"] as? String ?? movie?.description,
                     originalTitle: dictionary["original_title"] as? String ?? movie?.originalTitle,
                     originalLanguageCode: dictionary["original_language"] as? String ?? movie?.originalLanguageCode,
                     releaseDate: releaseDate ?? movie?.releaseDate,
                     runtimeInMinutes: dictionary["runtime"] as? Int ?? movie?.runtimeInMinutes,
                     budget: dictionary["budget"] as? Int ?? movie?.budget,
                     revenue: dictionary["revenue"] as? Int ?? movie?.revenue,
                     popularity: dictionary["popularity"] as? Double ?? movie?.popularity,
                     voteAverage: dictionary["vote_average"] as? Double ?? movie?.voteAverage,
                     voteCount: dictionary["vote_count"] as? Int ?? movie?.voteCount,
                     status: dictionary["status"] as? String ?? movie?.status,
                     posterImagePath: dictionary["poster_path"] as? String ?? movie?.posterImagePath,
                     backdropImagePath: dictionary["backdrop_path"] as? String ?? movie?.backdropImagePath,
                     websitePath: dictionary["homepage"] as? String ?? movie?.websitePath,
                     isAdult: dictionary["adult"] as? Bool ?? movie?.isAdult)
    }
}

extension MoviesRepository: MoviesRepositoryProtocol {
    var numberOfMovies: Int {
        return loadedMovies.count
    }

    func movie(at index: Int) -> Movie? {
        if index + 10 > loadedMovies.count && index < totalNumberOfMovies {
            loadMovies()
        }

        guard index >= 0 && index < loadedMovies.count else { return nil }
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

        let completion: ([AnyHashable: Any]?, Error?) -> Void = { [weak self] (moviesDictionary, error) in
            self?.handleMoviesResponse(requestedPage: newPage, moviesDictionary: moviesDictionary, error: error)
        }

        if !currentSearchQuery.isEmpty {
            contentService.request(.searchMovies, query: currentSearchQuery, page: newPage, completion: completion)
        } else {
            contentService.request(.popularMovies, page: newPage, completion: completion)
        }
    }

    func refreshMovies() {
        genres = nil
        lastLoadedPage = 0
        totalNumberOfMovies = 0
        totalNumberOfPages = 0
        loadedMovies = []
        loadMovies()
    }

    func searchForMovies(searchQuery: String) {
        pendingSearchQuery = searchQuery
        performPendingSearchIfNeeded()
    }

    func loadMovieDetails(_ id: Int, completion: ((Movie?) -> Void)?) {
        contentService.request(.movie(id: id)) { [weak self] (movieDictionary, error) in
            if let error = error {
                print("Error while requesting details from movie \(id). Error message: \(error.localizedDescription)")
            }

            let movie: Movie? = self?.parseMovie(dictionary: movieDictionary, existingID: id)
            DispatchQueue.main.async {
                guard movie?.id == id else {
                    completion?(nil)
                    return
                }
                completion?(movie)
            }
        }
    }
}
