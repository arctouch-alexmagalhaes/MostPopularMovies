//
//  MovieCell.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/14/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

struct MovieCellViewData {
    let thumbnailURL: String?
    let title: String?
    let genres: String?
    let popularityScore: Double?
    let releaseYear: String?
}

class MovieCell: UITableViewCell {
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var releaseYearLabel: UILabel!
    private var currentThumbnailURL: String?

    func configureContents(_ cellViewData: MovieCellViewData) {
        titleLabel.text = cellViewData.title
        genreLabel.text = cellViewData.genres
        releaseYearLabel.text = cellViewData.releaseYear
        currentThumbnailURL = cellViewData.thumbnailURL
    }

    func configureThumbnail(_ image: UIImage?, url: String?) {
        guard currentThumbnailURL == url else { return }
        thumbnailImageView.image = image
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        genreLabel.text = nil
        releaseYearLabel.text = nil
        currentThumbnailURL = nil
    }
}
