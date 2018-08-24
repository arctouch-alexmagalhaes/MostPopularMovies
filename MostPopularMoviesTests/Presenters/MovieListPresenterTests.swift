//
//  MovieListPresenterTests.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import OHHTTPStubs
import XCTest

class MovieListPresenterTests: XCTestCase {
    private var presenter: MovieListPresenterProtocol!
    private var mockView: MockMovieListView!
    private let imagePath: String = "7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"
    private let searchQuery: String = "test"

    override func setUp() {
        super.setUp()
        mockView = MockMovieListView()
        presenter = MovieListPresenter(view: mockView,
                                       moviesRepository: MoviesRepository(),
                                       imagesRepository: ImagesRepository())

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

        let queryParameters = ["query": searchQuery]
        stub(condition: pathMatches(ContentRoute.searchMovies.rawValue) && containsQueryParams(queryParameters)) { _ in
            guard let stubPath = OHPathForFile("search_movie_query_test_page_1.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        mockView = nil
        presenter = nil
        super.tearDown()
    }

    func testNumberOfMoviesIsZeroInitially() {
        XCTAssertEqual(0, presenter.numberOfMovies)
    }

    func testMoviesAreLoadedAfterViewLoads() {
        XCTAssertEqual(0, presenter.numberOfMovies)

        let expect = expectation(description: "movies are loaded after view loads")

        mockView.didReloadDataBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.presenter.numberOfMovies)
            expect.fulfill()
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMoviesAreReloadedAfterViewRefreshes() {
        XCTAssertEqual(0, presenter.numberOfMovies)

        let expect = expectation(description: "movies are reloaded after view refreshes")

        mockView.didReloadDataBlock = { [unowned self] isInitialLoad in
            XCTAssertEqual(20, self.presenter.numberOfMovies)
            if isInitialLoad {
                self.presenter.viewDidStartRefreshing()
            } else {
                expect.fulfill()
            }
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieAtInvalidIndexPathReturnsNilViewData() {
        XCTAssertEqual(0, presenter.numberOfMovies)

        let expect = expectation(description: "movies at invalid index path returns nil view data")

        mockView.didReloadDataBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.presenter.numberOfMovies)
            let negativeIndexPath = IndexPath(row: -1, section: 0)
            XCTAssertNil(self.presenter.movie(at: negativeIndexPath))
            let outOfRangeIndexPath = IndexPath(row: 100, section: 0)
            XCTAssertNil(self.presenter.movie(at: outOfRangeIndexPath))
            expect.fulfill()
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieAtValidIndexPathReturnsCorrectViewData() {
        XCTAssertEqual(0, presenter.numberOfMovies)

        let expect = expectation(description: "movie at first index has a popular movie")

        mockView.didReloadDataBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.presenter.numberOfMovies)

            let movieViewData = self.presenter.movie(at: IndexPath(row: 0, section: 0))
            XCTAssertNotNil(movieViewData)
            XCTAssertEqual("/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", movieViewData?.thumbnailURL)
            XCTAssertEqual("Avengers: Infinity War", movieViewData?.title)
            XCTAssertEqual(true, movieViewData?.genres?.contains("Adventure"))
            XCTAssertEqual(true, movieViewData?.genres?.contains("Science Fiction"))
            XCTAssertEqual(true, movieViewData?.genres?.contains("Fantasy"))
            XCTAssertEqual(true, movieViewData?.genres?.contains("Action"))
            XCTAssertEqual(275.362, movieViewData?.popularityScore)
            XCTAssertEqual("(2018)", movieViewData?.releaseYear)

            expect.fulfill()
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMoviePosterWithValidURLReturnsNonNilImage() {
        let expect = expectation(description: "load movie poster with valid url returns non-nil image")

        mockView.didReloadDataBlock = { [unowned self] _ in
            self.presenter.loadMoviePoster(self.imagePath, width: 342) { image in
                XCTAssertNotNil(image)
                expect.fulfill()
            }
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMoviePosterWithNilURLReturnsNilImage() {
        let expect = expectation(description: "load movie poster with nil url returns nil image")

        mockView.didReloadDataBlock = { [unowned self] _ in
            self.presenter.loadMoviePoster(nil, width: 342) { image in
                XCTAssertNil(image)
                expect.fulfill()
            }
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMoviesAreReloadedAfterSearchTextChanges() {
        XCTAssertEqual(0, presenter.numberOfMovies)

        let expect = expectation(description: "movies are reloaded after search text changes")

        mockView.didReloadDataBlock = { [unowned self] isInitialLoad in
            XCTAssertEqual(20, self.presenter.numberOfMovies)
            if isInitialLoad {
                self.presenter.searchTextDidChange(self.searchQuery)
            } else {
                expect.fulfill()
            }
        }
        presenter.viewDidLoad()

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
