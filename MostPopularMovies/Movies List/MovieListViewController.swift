//
//  MovieListViewController.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

protocol MovieListViewProtocol: class {
    func dataIsReady()
}

class MovieListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let movieCellHeight: CGFloat = 140
    private let movieCellIdentifier = "movieCellIdentifier"
    private let movieDetailsSegueIdentifier = "movieDetailsSegue"
    private lazy var presenter: MovieListPresenterProtocol = MovieListPresenter(view: self)
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = movieCellHeight
        presenter.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == movieDetailsSegueIdentifier,
            let movieDetailsView = segue.destination as? MovieDetailsViewProtocol else {
            return
        }

        movieDetailsView.movieIndexPath = selectedIndexPath
    }
}

extension MovieListViewController: MovieListViewProtocol {
    func dataIsReady() {
        tableView.reloadData()
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfMovies
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movieCell = tableView.dequeueReusableCell(withIdentifier: movieCellIdentifier) as? MovieCell else {
            return UITableViewCell()
        }

        if let movieViewData = presenter.movie(at: indexPath) {
            movieCell.configureContents(movieViewData)
            presenter.movieThumbnail(movieViewData.thumbnailURL) { image in
                movieCell.configureThumbnail(image, url: movieViewData.thumbnailURL)
            }
        }
        return movieCell
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: movieDetailsSegueIdentifier, sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
