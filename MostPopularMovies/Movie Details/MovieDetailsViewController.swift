//
//  MovieDetailsViewController.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

protocol MovieDetailsViewProtocol: class {
    var movieIndexPath: IndexPath? { get set }
}

class MovieDetailsViewController: UIViewController {
    private lazy var presenter: MovieDetailsPresenterProtocol = MovieDetailsPresenter(view: self)
    var movieIndexPath: IndexPath?
}

extension MovieDetailsViewController: MovieDetailsViewProtocol {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let movieIndexPath = movieIndexPath else { return }
        let movieDetails = presenter.movieDetails(at: movieIndexPath)
        title = movieDetails.title
    }
}
