//
//  MovieListViewController.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

protocol MovieListViewProtocol: class {

}

class MovieListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let movieCellIdentifier = "movieCellIdentifier"
    private let movieDetailsSegueIdentifier = "movieDetailsSegue"
    private lazy var presenter: MovieListPresenterProtocol = MovieListPresenter(view: self)
    private var selectedIndexPath: IndexPath?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == movieDetailsSegueIdentifier,
            let movieDetailsView = segue.destination as? MovieDetailsViewProtocol else {
            return
        }

        movieDetailsView.movieIndexPath = selectedIndexPath
    }
}

extension MovieListViewController: MovieListViewProtocol {
    
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfMovies
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movieCell = tableView.dequeueReusableCell(withIdentifier: movieCellIdentifier) else {
            return UITableViewCell()
        }

        let movieData = presenter.movie(at: indexPath)
        movieCell.textLabel?.text = movieData.title
        return movieCell
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: movieDetailsSegueIdentifier, sender: self)
    }
}
