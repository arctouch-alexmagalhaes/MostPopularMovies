//
//  MovieListViewController.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

protocol MovieListViewProtocol: class {
    func reloadData(scrollingToTop: Bool)
}

class MovieListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let movieCellHeight: CGFloat = 140
    private let movieCellIdentifier = "movieCellIdentifier"
    private let movieDetailsSegueIdentifier = "movieDetailsSegue"
    private lazy var presenter: MovieListPresenterProtocol = MovieListPresenter(view: self)
    private var selectedIndexPath: IndexPath?
    private var highestPopularity: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = movieCellHeight
        tableView.tableFooterView = UIView()
        addSearchBar()
        presenter.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == movieDetailsSegueIdentifier,
            let movieDetailsView = segue.destination as? MovieDetailsViewProtocol else {
            return
        }

        movieDetailsView.movieIndexPath = selectedIndexPath
    }

    private func addSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a movie"
        searchBar.delegate = self
        searchBar.tintColor = .magenta
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
    }
}

extension MovieListViewController: MovieListViewProtocol {
    func reloadData(scrollingToTop: Bool) {
        // This was the only approach that worked on iOS 11
        if scrollingToTop {
            tableView.setContentOffset(.zero, animated: false)
        }
        tableView.reloadData()
        if scrollingToTop {
            tableView.layoutIfNeeded()
            tableView.setContentOffset(.zero, animated: false)
        }
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
            let popularityScore = movieViewData.popularityScore ?? 0.0
            if indexPath.row == 0 {
                highestPopularity = popularityScore
            }
            let popularityColor = popularityScore.popularityColor(highestPopularity: highestPopularity)

            movieCell.configureContents(movieViewData, popularityColor: popularityColor)
            presenter.loadMoviePoster(movieViewData.thumbnailURL, width: movieCell.thumbnailSize.width) { image in
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchTextDidChange(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        presenter.searchTextDidChange("")
    }
}

private extension Double {
    private var highestPopularityGreenValue: CGFloat { return 205.0 }
    private var highestPopularityBlueValue: CGFloat { return 0.0 }
    private var lowestPopularityGreenValue: CGFloat { return 255.0 }
    private var lowestPopularityBlueValue: CGFloat { return 255.0 }

    func popularityColor(highestPopularity: Double) -> UIColor {
        let ratio: CGFloat = CGFloat(self / highestPopularity)

        let greenRange = highestPopularityGreenValue - lowestPopularityGreenValue
        let green: CGFloat = ratio * greenRange + lowestPopularityGreenValue

        let blueRange = highestPopularityBlueValue - lowestPopularityBlueValue
        let blue: CGFloat = ratio * blueRange + lowestPopularityBlueValue

        return UIColor(red: 1.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}
