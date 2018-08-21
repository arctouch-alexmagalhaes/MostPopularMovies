//
//  MovieDetailsPresenter.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

protocol MovieDetailsPresenterProtocol: class {
    func movieTitle(at indexPath: IndexPath) -> String?
    func movieBackdrop(at indexPath: IndexPath, width: CGFloat, completion: ((UIImage?) -> Void)?)
    func moviePoster(at indexPath: IndexPath, width: CGFloat, completion: ((UIImage?) -> Void)?)
    func movieDetails(at indexPath: IndexPath, completion: ((MovieDetailsViewData?) -> Void)?)
    func didTapWebsite(at indexPath: IndexPath)
}

class MovieDetailsPresenter {
    private weak var view: MovieDetailsViewProtocol?
    private let moviesRepository: MoviesRepositoryProtocol = MoviesRepository.shared
    private let imagesRepository: ImagesRepositoryProtocol = ImagesRepository.shared
    private let font = UIFont.systemFont(ofSize: 17.0)
    private let sectionTitleColor: UIColor = .magenta
    private let sectionContentColor: UIColor = .mediumCyanBlue
    private lazy var sectionTitleAttributes = [NSAttributedStringKey.font: font,
                                               NSAttributedStringKey.foregroundColor: sectionTitleColor]
    private lazy var sectionContentAttributes = [NSAttributedStringKey.font: font,
                                                 NSAttributedStringKey.foregroundColor: sectionContentColor]

    init(view: MovieDetailsViewProtocol) {
        self.view = view
    }

    private func createMovieDetailsViewData(from movie: Movie) -> MovieDetailsViewData {
        let genreString = movie.genres?.joined(separator: ", ")
        let genres = sectionAttributedString(title: "Genre: ", content: genreString)

        var releaseYear: String?
        if let releaseDate = movie.releaseDate {
            releaseYear = "\(Calendar.current.component(.year, from: releaseDate))"
        }

        let description: NSAttributedString? = descriptionAttributedText(from: movie.description)
        let runtime: String? = runtimeText(from: movie.runtimeInMinutes)
        let revenue: NSAttributedString? = revenueAttributedText(from: movie.revenue)

        var languages: NSAttributedString?
        if let languageString = movie.languages?.joined(separator: ", "), !languageString.isEmpty {
            languages = sectionAttributedString(title: "Language: ", content: languageString)
        }

        let websiteLink: NSAttributedString? = websiteAttributedText(from: movie.websitePath)
        
        let viewData = MovieDetailsViewData(backdropImageURL: movie.backdropImagePath,
                                            posterImageURL: movie.posterImagePath,
                                            title: movie.title,
                                            genres: genres,
                                            popularityScore: movie.popularity,
                                            releaseYear: releaseYear,
                                            description: description,
                                            runtime: runtime,
                                            revenue: revenue,
                                            languages: languages,
                                            websiteLink: websiteLink)
        return viewData
    }

    private func sectionAttributedString(title: String, content: String?) -> NSAttributedString? {
        guard let content = content else { return nil }
        let sectionTitle = NSAttributedString(string: title, attributes: sectionTitleAttributes)
        let sectionContent = NSAttributedString(string: content, attributes: sectionContentAttributes)
        let sectionMutableString = NSMutableAttributedString(attributedString: sectionTitle)
        sectionMutableString.append(sectionContent)
        return NSAttributedString(attributedString: sectionMutableString)
    }

    private func descriptionAttributedText(from descriptionText: String?) -> NSAttributedString? {
        guard let descriptionString = descriptionText else { return nil }
        let font: UIFont = UIFont.systemFont(ofSize: 14.0)
        let color: UIColor = .darkBlueMagenta
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20.0
        paragraphStyle.maximumLineHeight = 20.0
        let attributes = [NSAttributedStringKey.font: font,
                          NSAttributedStringKey.foregroundColor: color,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
        return NSAttributedString(string: descriptionString, attributes: attributes)
    }

    private func runtimeText(from runtimeInMinutes: Int?) -> String? {
        guard let runtimeInMinutes = runtimeInMinutes else { return nil }
        let hours: Int = runtimeInMinutes / 60
        let minutes: Int = runtimeInMinutes - 60 * hours
        let runtime: String
        if hours > 0 {
            runtime = "\(hours)h \(minutes)min"
        } else {
            runtime = "\(minutes)min"
        }
        return runtime
    }

    private func revenueAttributedText(from revenue: Int?) -> NSAttributedString? {
        guard let revenue = revenue, revenue > 0 else { return nil }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.positivePrefix = "$"
        let formattedRevenue = numberFormatter.string(from: NSNumber(value: revenue))
        return sectionAttributedString(title: "Worldwide Gross: ", content: formattedRevenue)
    }

    private func websiteAttributedText(from website: String?) -> NSAttributedString? {
        guard var website = website else { return nil }
        website = website.replacingOccurrences(of: "https://", with: "")
        website = website.replacingOccurrences(of: "http://", with: "")
        let font: UIFont = UIFont.systemFont(ofSize: 14.0)
        let titleColor: UIColor = .darkBlueMagenta
        let titleAttributes = [NSAttributedStringKey.font: font,
                               NSAttributedStringKey.foregroundColor: titleColor]
        let title = NSAttributedString(string: "Website: ", attributes: titleAttributes)
        let contentColor: UIColor = .mediumBlueMagenta
        let contentAttributes = [NSAttributedStringKey.font: font,
                                 NSAttributedStringKey.foregroundColor: contentColor]
        let content = NSAttributedString(string: website, attributes: contentAttributes)
        let websiteMutableString = NSMutableAttributedString(attributedString: title)
        websiteMutableString.append(content)
        return NSAttributedString(attributedString: websiteMutableString)
    }
}

extension MovieDetailsPresenter: MovieDetailsPresenterProtocol {
    func movieTitle(at indexPath: IndexPath) -> String? {
        guard indexPath.row < moviesRepository.numberOfMovies else { return nil }
        let movie = moviesRepository.movie(at: indexPath.row)
        return movie.title
    }

    func movieBackdrop(at indexPath: IndexPath, width: CGFloat, completion: ((UIImage?) -> Void)?) {
        guard indexPath.row < moviesRepository.numberOfMovies else {
            completion?(nil)
            return
        }

        let movie = moviesRepository.movie(at: indexPath.row)
        imagesRepository.loadBackdropImage(movie.backdropImagePath, width: Int(width)) { data in
            guard let data = data else {
                completion?(nil)
                return
            }
            completion?(UIImage(data: data))
        }
    }

    func moviePoster(at indexPath: IndexPath, width: CGFloat, completion: ((UIImage?) -> Void)?) {
        guard indexPath.row < moviesRepository.numberOfMovies else {
            completion?(nil)
            return
        }

        let movie = moviesRepository.movie(at: indexPath.row)
        imagesRepository.loadPosterImage(movie.posterImagePath, width: Int(width)) { data in
            guard let data = data else {
                completion?(nil)
                return
            }
            completion?(UIImage(data: data))
        }
    }

    func movieDetails(at indexPath: IndexPath, completion: ((MovieDetailsViewData?) -> Void)?) {
        guard indexPath.row < moviesRepository.numberOfMovies,
            let movieID = moviesRepository.movie(at: indexPath.row).id else {
                completion?(nil)
                return
        }

        moviesRepository.loadMovieDetails(movieID) { [weak self] movie in
            guard let movie = movie else {
                completion?(nil)
                return
            }

            let viewData = self?.createMovieDetailsViewData(from: movie)
            completion?(viewData)
        }
    }

    func didTapWebsite(at indexPath: IndexPath) {
        guard indexPath.row < moviesRepository.numberOfMovies else { return }
        let movie = moviesRepository.movie(at: indexPath.row)
        guard let websitePath = movie.websitePath, let websiteURL = URL(string: websitePath) else { return }
        let viewController = SFSafariViewController(url: websiteURL)
        view?.present(viewController, animated: true, completion: nil)
    }
}
