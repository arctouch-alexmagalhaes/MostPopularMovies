//
//  MoviesRepositoryTests.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import OHHTTPStubs
import XCTest

class MoviesRepositoryTests: XCTestCase {
    private var moviesRepository: MoviesRepositoryProtocol!
    // swiftlint:disable weak_delegate
    private var mockMoviesRepositoryDelegate: MockMoviesRepositoryDelegate!
    private let searchQuery: String = "test"
    private let avengersMovieID: Int = 299536

    override func setUp() {
        super.setUp()
        moviesRepository = MoviesRepository()
        mockMoviesRepositoryDelegate = MockMoviesRepositoryDelegate()
        moviesRepository.delegate = mockMoviesRepositoryDelegate
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

        let page = 2
        let pageParameters = ["page": String(page)]
        stub(condition: pathMatches(ContentRoute.popularMovies.rawValue) && containsQueryParams(pageParameters)) { _ in
            guard let stubPath = OHPathForFile("movie_popular_page_\(page).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let queryParameters = ["query": searchQuery]
        stub(condition: pathMatches(ContentRoute.searchMovies.rawValue) && containsQueryParams(queryParameters)) { _ in
            guard let stubPath = OHPathForFile("search_movie_query_test_page_1.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let pageAndQueryParameters = ["page": String(page),
                                      "query": searchQuery]
        let condition = pathMatches(ContentRoute.searchMovies.rawValue)
            && containsQueryParams(pageAndQueryParameters)
        stub(condition: condition) { _ in
            guard let stubPath = OHPathForFile("search_movie_query_test_page_\(page).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: pathMatches(ContentRoute.movie(id: avengersMovieID).rawValue)) { [unowned self] _ in
            guard let stubPath = OHPathForFile("movie_\(self.avengersMovieID).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: pathMatches(ContentRoute.movie(id: -1).rawValue)) { [unowned self] _ in
            guard let stubPath = OHPathForFile("movie_invalid.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, status: 404, headers: ["Content-Type": "application/json"])
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        mockMoviesRepositoryDelegate = nil
        moviesRepository = nil
        super.tearDown()
    }
}

// MARK: - Movies Repository Tests
extension MoviesRepositoryTests {
    func testNumberOfMoviesIsInitiallyZero() {
        XCTAssertEqual(0, moviesRepository.numberOfMovies)
    }

    func testMovieAtIndexOutOfRangeReturnsNil() {
        XCTAssertNil(moviesRepository.movie(at: 0))
    }

    func testMovieAtIndexAfterLoadingMoviesReturnsAMovie() {
        let expect = expectation(description: "getting movie after loading 1 page of movies returns a movie")

        moviesRepository.loadMovies()
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertNotNil(self.moviesRepository.movie(at: 0))
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMoviesIncreasesTheNumberOfMovies() {
        let expect = expectation(description: "loading 1 page of movies increases number of movies to 20")

        moviesRepository.loadMovies()
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMoviesReturnsACompleteMovie() {
        let expect = expectation(description: "list of popular movies has a movie with all information we need")

        moviesRepository.loadMovies()
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            let movie = self.moviesRepository.movie(at: 0)
            XCTAssertNotNil(movie)
            XCTAssertEqual(self.avengersMovieID, movie?.id)
            XCTAssertEqual("Avengers: Infinity War", movie?.title)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let releaseDate = dateFormatter.date(from: "2018-04-25")
            XCTAssertEqual(releaseDate, movie?.releaseDate)
            XCTAssertEqual(275.362, movie?.popularity)
            XCTAssertEqual(4, movie?.genres?.count)
            XCTAssertEqual(true, movie?.genres?.contains("Action"))
            XCTAssertEqual("/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", movie?.posterImagePath)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMoviesTwiceIncreasesTheNumberOfMoviesTwice() {
        let expect = expectation(description: "loading 2 pages of movies increases number of movies to 40")

        moviesRepository.loadMovies()
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            self.moviesRepository.loadMovies()
        }
        mockMoviesRepositoryDelegate.didUpdateBlock = { [unowned self] in
            XCTAssertEqual(40, self.moviesRepository.numberOfMovies)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testRefreshMoviesClearsListOfMoviesAndReloads() {
        let expect = expectation(description: "refreshing movies clears and reloads the list of movies")

        moviesRepository.loadMovies()
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] isInitialLoad in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            XCTAssertNotNil(self.moviesRepository.movie(at: 0))
            if isInitialLoad {
                self.moviesRepository.refreshMovies()
                XCTAssertEqual(0, self.moviesRepository.numberOfMovies)
                XCTAssertNil(self.moviesRepository.movie(at: 0))
            } else {
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchForMoviesIncreasesTheNumberOfMovies() {
        let expect = expectation(description: "loading 1 page of the search results increases number of movies to 20")

        moviesRepository.searchForMovies(searchQuery: searchQuery)
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieAtIndexAfterSearchingForMoviesReturnsAMovie() {
        let expect = expectation(description: "getting movie after searching for movies returns a movie")

        moviesRepository.searchForMovies(searchQuery: searchQuery)
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertNotNil(self.moviesRepository.movie(at: 0))
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchForMoviesAndLoadTwoPagesIncreasesTheNumberOfMoviesTwice() {
        let expect = expectation(description: "loading 2 pages of search results increases number of movies to 40")

        moviesRepository.searchForMovies(searchQuery: searchQuery)
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            self.moviesRepository.loadMovies()
        }
        mockMoviesRepositoryDelegate.didUpdateBlock = { [unowned self] in
            XCTAssertEqual(40, self.moviesRepository.numberOfMovies)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testRefreshMoviesAfterSearchClearsListOfMoviesAndReloadsSearchResults() {
        let expect = expectation(description: "refreshing movies clears and reloads the list of search results")

        var firstMovieID: Int?
        moviesRepository.searchForMovies(searchQuery: searchQuery)
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] isInitialLoad in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            let firstMovie = self.moviesRepository.movie(at: 0)
            XCTAssertNotNil(firstMovie)
            if isInitialLoad {
                firstMovieID = firstMovie?.id
                self.moviesRepository.refreshMovies()
                XCTAssertEqual(0, self.moviesRepository.numberOfMovies)
                XCTAssertNil(self.moviesRepository.movie(at: 0))
            } else {
                XCTAssertNotNil(firstMovie?.id)
                XCTAssertEqual(firstMovieID, firstMovie?.id)
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMovieDetailsReturnsMoreInformationAboutAMovie() {
        let expect = expectation(description: "load movie details returns more information about a movie")

        moviesRepository.loadMovies()
        mockMoviesRepositoryDelegate.didReloadBlock = { [unowned self] _ in
            XCTAssertEqual(20, self.moviesRepository.numberOfMovies)
            let movie = self.moviesRepository.movie(at: 0)
            XCTAssertNotNil(movie)
            XCTAssertEqual(self.avengersMovieID, movie?.id)

            self.moviesRepository.loadMovieDetails(self.avengersMovieID, completion: { movie in
                XCTAssertEqual("Avengers: Infinity War", movie?.title)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let releaseDate = dateFormatter.date(from: "2018-04-25")
                XCTAssertEqual(releaseDate, movie?.releaseDate)
                XCTAssertEqual(275.362, movie?.popularity)
                XCTAssertEqual(4, movie?.genres?.count)
                XCTAssertEqual(true, movie?.genres?.contains("Action"))
                XCTAssertEqual("/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", movie?.posterImagePath)
                XCTAssertEqual(149, movie?.runtimeInMinutes)
                XCTAssertEqual("English", movie?.languages?.first)
                XCTAssertEqual(2045186856, movie?.revenue)
                let descriptionSnippet = "As the Avengers and their allies have continued to protect the world"
                XCTAssertEqual(true, movie?.description?.starts(with: descriptionSnippet))
                XCTAssertEqual(true, movie?.websitePath?.starts(with: "http://marvel.com/movies"))
                expect.fulfill()
            })
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadMovieDetailsOfInvalidIDReturnsNilMovie() {
        let expect = expectation(description: "load movie details of non existent movie returns nil")

        moviesRepository.loadMovieDetails(-1, completion: { movie in
            XCTAssertNil(movie)
            expect.fulfill()
        })

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
