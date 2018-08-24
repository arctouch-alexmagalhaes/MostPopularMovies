//
//  MockMovieDetailsView.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import UIKit

class MockMovieDetailsView: MovieDetailsViewProtocol {
    var didPresentViewControllerBlock: (() -> Void)?
    var movieIndexPath: IndexPath?

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        didPresentViewControllerBlock?()
    }
}
