//
//  MockMovieListView.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies

class MockMovieListView: MovieListViewProtocol {
    var didReloadDataBlock: ((_ isInitialLoad: Bool) -> Void)?
    var didShowErrorMessageBlock: (() -> Void)?
    var didShowLoadingViewBlock: (() -> Void)?
    var didHideLoadingViewBlock: (() -> Void)?
    private(set) var isInitialLoad: Bool = true

    func reloadData(scrollingToTop: Bool) {
        didReloadDataBlock?(isInitialLoad)
        isInitialLoad = false
    }

    func showErrorMessage() {
        didShowErrorMessageBlock?()
    }

    func showLoadingView() {
        didShowLoadingViewBlock?()
    }

    func hideLoadingView() {
        didHideLoadingViewBlock?()
    }
}
