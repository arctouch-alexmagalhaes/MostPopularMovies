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
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

class MovieDetailsViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var backdropImageView: UIImageView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsView: UIView!
    @IBOutlet private weak var releaseYearAndRuntimeLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var revenueLabel: UILabel!
    @IBOutlet private weak var popularityLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var websiteLabel: UILabel!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    private lazy var presenter: MovieDetailsPresenterProtocol = MovieDetailsPresenter(view: self)
    private var backdropGradient: CAGradientLayer?
    var movieIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientToBackdropImageView()
        detailsView.alpha = 0.0
        popularityLabel.alpha = 0.0
        popularityLabel.layer.cornerRadius = popularityLabel.frame.size.height / 2.0
        popularityLabel.layer.masksToBounds = true
        descriptionLabel.alpha = 0.0
        websiteLabel.alpha = 0.0
        let websiteTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebsiteLabel))
        websiteLabel.addGestureRecognizer(websiteTapGestureRecognizer)
        websiteLabel.isUserInteractionEnabled = true

        loadContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentSize()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.applyGradientToBackdropImageView()
            self?.updateScrollViewContentSize()
        }, completion: nil)
    }

    private func loadContent() {
        guard let movieIndexPath = movieIndexPath else { return }
        let movieTitle = presenter.movieTitle(at: movieIndexPath)
        title = movieTitle
        titleLabel.text = movieTitle

        loadingView.alpha = 1.0
        presenter.movieDetails(at: movieIndexPath) { [weak self] viewData in
            guard let strongSelf = self else { return }
            strongSelf.titleLabel.text = viewData?.title
            strongSelf.releaseYearAndRuntimeLabel.text = viewData?.releaseYearAndRuntime
            strongSelf.genreLabel.attributedText = viewData?.genres
            strongSelf.languageLabel.attributedText = viewData?.languages
            strongSelf.revenueLabel.attributedText = viewData?.revenue
            let popularityLabelAlpha: CGFloat
            if let popularityScore = viewData?.popularityScore {
                strongSelf.popularityLabel.text = "\(Int(popularityScore))"
                popularityLabelAlpha = 1.0
            } else {
                strongSelf.popularityLabel.text = nil
                popularityLabelAlpha = 0.0
            }
            strongSelf.descriptionLabel.attributedText = viewData?.description
            strongSelf.websiteLabel.attributedText = viewData?.websiteLink
            strongSelf.view.setNeedsLayout()
            strongSelf.view.layoutIfNeeded()
            strongSelf.updateScrollViewContentSize()
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.loadingView.alpha = 0.0
                strongSelf.detailsView.alpha = 1.0
                strongSelf.popularityLabel.alpha = popularityLabelAlpha
                strongSelf.descriptionLabel.alpha = 1.0
                strongSelf.websiteLabel.alpha = 1.0
            })
        }

        presenter.movieBackdrop(at: movieIndexPath, width: backdropImageView.frame.width) { [weak self] image in
            guard let strongSelf = self else { return }
            UIView.transition(with: strongSelf.backdropImageView,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in self?.backdropImageView.image = image },
                              completion: nil)
        }

        presenter.moviePoster(at: movieIndexPath, width: posterImageView.frame.width) { [weak self] image in
            guard let strongSelf = self else { return }
            UIView.transition(with: strongSelf.posterImageView,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in self?.posterImageView.image = image },
                              completion: nil)
        }
    }

    private func applyGradientToBackdropImageView() {
        if let currentGradient = backdropGradient {
            currentGradient.removeFromSuperlayer()
        }
        let gradient = CAGradientLayer()
        let backdropWidth = UIScreen.main.bounds.width
        let backdropSize = CGSize(width: backdropWidth, height: (backdropWidth - 50.0) * 9 / 16)
        gradient.frame = CGRect(origin: .zero, size: backdropSize)
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.7)
        gradient.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(1.0).cgColor
        ]
        backdropImageView.layer.addSublayer(gradient)
        backdropGradient = gradient
    }

    private func updateScrollViewContentSize() {
        let contentMaxY = max(posterImageView.frame.maxY, websiteLabel.frame.maxY)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentMaxY + 12.0)
    }

    @objc private func didTapWebsiteLabel() {
        guard let indexPath = movieIndexPath else { return }
        presenter.didTapWebsite(at: indexPath)
    }
}

extension MovieDetailsViewController: MovieDetailsViewProtocol { }
