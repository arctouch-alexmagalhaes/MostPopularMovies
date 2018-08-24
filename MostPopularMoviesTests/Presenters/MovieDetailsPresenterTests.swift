//
//  MovieDetailsPresenterTests.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import OHHTTPStubs
import XCTest

class MovieDetailsPresenterTests: XCTestCase {
    private var moviesRepository: MoviesRepositoryProtocol!
    // swiftlint:disable weak_delegate
    private var mockMoviesRepositoryDelegate: MockMoviesRepositoryDelegate!
    private var imagesRepository: ImagesRepositoryProtocol!
    private var presenter: MovieDetailsPresenterProtocol!
    private var mockView: MockMovieDetailsView!
    private let indexPath: IndexPath = IndexPath(row: 0, section: 0)
    private let imagePath: String = "7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"
    private let avengersMovieID: Int = 299536

    override func setUp() {
        super.setUp()
        moviesRepository = MoviesRepository()
        mockMoviesRepositoryDelegate = MockMoviesRepositoryDelegate()
        moviesRepository.delegate = mockMoviesRepositoryDelegate
        imagesRepository = ImagesRepository()
        mockView = MockMovieDetailsView()
        presenter = MovieDetailsPresenter(view: mockView,
                                          moviesRepository: moviesRepository,
                                          imagesRepository: imagesRepository)

        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: pathMatches(ContentRoute.movieGenres.rawValue)) { _ in
            guard let stubPath = OHPathForFile("genre_movie_list.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: pathMatches(ContentRoute.popularMovies.rawValue)) { _ in
            guard let stubPath = OHPathForFile("movie_popular_page_1.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isExtension("jpg")) { [unowned self] _ in
            guard let stubPath = OHPathForFile(self.imagePath, type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "image/jpeg"])
        }

        stub(condition: pathMatches(ContentRoute.movie(id: avengersMovieID).rawValue)) { [unowned self] _ in
            guard let stubPath = OHPathForFile("movie_\(self.avengersMovieID).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        mockMoviesRepositoryDelegate = nil
        moviesRepository = nil
        imagesRepository = nil
        mockView = nil
        presenter = nil
        super.tearDown()
    }

    func testMovieTitleAtValidIndexPathReturnsCorrectValue() {
        let expect = expectation(description: "movie title at valid index path returns correct value")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            let movieTitle = self.presenter.movieTitle(at: self.indexPath)
            XCTAssertEqual("Avengers: Infinity War", movieTitle)
            expect.fulfill()
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieTitleAtInvalidIndexPathReturnsNil() {
        let movieTitle = self.presenter.movieTitle(at: IndexPath(row: -1, section: 0))
        XCTAssertNil(movieTitle)
    }

    func testMovieBackdropAtValidIndexPathReturnsCorrectValue() {
        let expect = expectation(description: "movie backdrop at valid index path returns correct value")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            self.presenter.movieBackdrop(at: self.indexPath, width: 342, completion: { image in
                XCTAssertNotNil(image)
                expect.fulfill()
            })
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieBackdropAtInvalidIndexPathReturnsNil() {
        let expect = expectation(description: "movie backdrop at invalid index path returns nil")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            let invalidIndexPath = IndexPath(row: -1, section: 0)
            self.presenter.movieBackdrop(at: invalidIndexPath, width: 342, completion: { image in
                XCTAssertNil(image)
                expect.fulfill()
            })
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMoviePosterAtValidIndexPathReturnsCorrectValue() {
        let expect = expectation(description: "movie poster at valid index path returns correct value")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            self.presenter.moviePoster(at: self.indexPath, width: 342, completion: { image in
                XCTAssertNotNil(image)
                expect.fulfill()
            })
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMoviePosterAtInvalidIndexPathReturnsNil() {
        let expect = expectation(description: "movie poster at invalid index path returns nil")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            let invalidIndexPath = IndexPath(row: -1, section: 0)
            self.presenter.moviePoster(at: invalidIndexPath, width: 342, completion: { image in
                XCTAssertNil(image)
                expect.fulfill()
            })
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieDetailsAtValidIndexPathReturnsCorrectValue() {
        let expect = expectation(description: "movie details at valid index path returns correct value")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            self.presenter.movieDetails(at: self.indexPath, completion: { movieViewData in
                XCTAssertNotNil(movieViewData)
                XCTAssertEqual("/bOGkgRGdhrBYJSLpXaxhXVstddV.jpg", movieViewData?.backdropImageURL)
                XCTAssertEqual("/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", movieViewData?.posterImageURL)
                XCTAssertEqual("Avengers: Infinity War", movieViewData?.title)
                XCTAssertEqual(true, movieViewData?.genres?.string.contains("Adventure"))
                XCTAssertEqual(true, movieViewData?.genres?.string.contains("Science Fiction"))
                XCTAssertEqual(true, movieViewData?.genres?.string.contains("Fantasy"))
                XCTAssertEqual(true, movieViewData?.genres?.string.contains("Action"))
                XCTAssertEqual(275.362, movieViewData?.popularityScore)
                XCTAssertEqual(true, movieViewData?.releaseYearAndRuntime?.contains("2018"))
                XCTAssertEqual(true, movieViewData?.languages?.string.contains("English"))
                XCTAssertEqual(true, movieViewData?.websiteLink?.string.contains("marvel.com"))
                expect.fulfill()
            })
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieDetailsAtInvalidIndexPathReturnsNil() {
        let expect = expectation(description: "movie details at invalid index path returns nil")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            let invalidIndexPath = IndexPath(row: -1, section: 0)
            self.presenter.movieDetails(at: invalidIndexPath, completion: { movieViewData in
                XCTAssertNil(movieViewData)
                expect.fulfill()
            })
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testPresentViewIfDidTapWebsiteAtValidIndexPath() {
        let expect = expectation(description: "present view if did tap website at valid index path")

        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            self.presenter.movieDetails(at: self.indexPath, completion: { [unowned self] _ in
                self.presenter.didTapWebsite(at: self.indexPath)
            })
        }

        mockView.didPresentViewControllerBlock = {
            expect.fulfill()
        }

        imagesRepository.loadConfiguration { [unowned self] in
            self.moviesRepository.loadMovies()
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
