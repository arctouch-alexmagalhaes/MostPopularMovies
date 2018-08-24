//
//  MockMoviesRepositoryDelegate.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies

class MockMoviesRepositoryDelegate: MoviesRepositoryDelegate {
    var didReloadBlock: ((_ isInitialLoad: Bool) -> Void)?
    var didUpdateBlock: (() -> Void)?
    var didFailBlock: (() -> Void)?
    private(set) var isInitialLoad: Bool = true

    func moviesRepositoryDidReloadListOfMovies(_ moviesRepository: MoviesRepositoryProtocol) {
        didReloadBlock?(isInitialLoad)
        isInitialLoad = false
    }

    func moviesRepositoryDidUpdateListOfMovies(_ moviesRepository: MoviesRepositoryProtocol) {
        didUpdateBlock?()
    }

    func moviesRepositoryDidFailLoadingMovies(_ moviesRepository: MoviesRepositoryProtocol) {
        didFailBlock?()
    }
}
