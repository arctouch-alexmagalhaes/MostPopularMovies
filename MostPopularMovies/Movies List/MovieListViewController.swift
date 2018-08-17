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
    private var highestPopularity: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = movieCellHeight
        tableView.tableFooterView = UIView()
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
            let popularityScore = movieViewData.popularityScore ?? 0.0
            if indexPath.row == 0 {
                highestPopularity = popularityScore
            }
            let popularityColor = popularityScore.popularityColor(highestPopularity: highestPopularity)

            movieCell.configureContents(movieViewData, popularityColor: popularityColor)
            presenter.moviePoster(movieViewData.thumbnailURL, width: movieCell.thumbnailSize.width) { image in
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
