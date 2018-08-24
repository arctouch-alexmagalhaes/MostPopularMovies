//
//  ContentServiceTests.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/23/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import OHHTTPStubs
import XCTest

// swiftlint:disable file_length
enum ContentServiceTestsError: Error {
    case noPathForStub
}

class ContentServiceTests: XCTestCase {
    private let contentService: ContentServiceProtocol = ContentService()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
}

// MARK: - Configuration Tests
extension ContentServiceTests {
    func testConfigurationRequestReturnsNonNilDictionary() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "configuration request successfully returns non-nil dictionary")

        contentService.request(.configuration) { (configurationDictionary, error) in
            XCTAssertNotNil(configurationDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testConfigurationRequestReturnsNonNilDictionaryIgnoringPageParameter() {
        let page = 2
        let parameters = ["page": String(page)]
        stub(condition: pathMatches(ContentRoute.configuration.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "configuration returns non-nil dictionary ignoring page parameter")

        contentService.request(.configuration, page: page) { (configurationDictionary, error) in
            XCTAssertNotNil(configurationDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testConfigurationRequestReturnsNonNilDictionaryIgnoringQueryParameter() {
        let query = "test"
        let parameters = ["query": query]
        stub(condition: pathMatches(ContentRoute.configuration.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "configuration returns non-nil dictionary ignoring query parameter")

        contentService.request(.configuration, query: query) { (configurationDictionary, error) in
            XCTAssertNotNil(configurationDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testConfigurationRequestReturnsNonNilDictionaryIgnoringPageAndQueryParameters() {
        let query = "test query"
        let page = 2
        let parameters = ["query": query,
                          "page": String(page)]
        stub(condition: pathMatches(ContentRoute.configuration.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "configuration returns non-nil dictionary ignoring parameters")

        contentService.request(.configuration, query: query, page: page) { (configurationDictionary, error) in
            XCTAssertNotNil(configurationDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - Popular Movies Tests
extension ContentServiceTests {
    func testPopularMoviesRequestReturnsNonNilDictionary() {
        stub(condition: pathMatches(ContentRoute.popularMovies.rawValue)) { _ in
            guard let stubPath = OHPathForFile("movie_popular_page_1.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "popular movies returns non-nil dictionary")

        contentService.request(.popularMovies) { (moviesDictionary, error) in
            XCTAssertNotNil(moviesDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testPopularMoviesRequestWithPageParameterReturnsNonNilDictionary() {
        let page = 2
        let parameters = ["page": String(page)]
        stub(condition: pathMatches(ContentRoute.popularMovies.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("movie_popular_page_\(page).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "popular movies with page returns non-nil dictionary")

        contentService.request(.popularMovies, page: page) { (moviesDictionary, error) in
            XCTAssertNotNil(moviesDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testPopularMoviesRequestReturnsNonNilDictionaryIgnoringQueryParameter() {
        let query = "test"
        let parameters = ["query": query]
        stub(condition: pathMatches(ContentRoute.popularMovies.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("movie_popular_page_1.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "popular movies returns non-nil dictionary ignoring query parameter")

        contentService.request(.popularMovies, query: query) { (moviesDictionary, error) in
            XCTAssertNotNil(moviesDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testPopularMoviesRequestWithPageParameterReturnsNonNilDictionaryIgnoringQueryParameter() {
        let query = "test"
        let page = 2
        let parameters = ["query": query,
                          "page": String(page)]
        stub(condition: pathMatches(ContentRoute.popularMovies.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("movie_popular_page_\(page).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "popular movies with page returns non-nil dictionary ignoring query")

        contentService.request(.popularMovies, query: query, page: page) { (moviesDictionary, error) in
            XCTAssertNotNil(moviesDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - Search Movies Tests
extension ContentServiceTests {
    func testSearchMoviesRequestWithNoQueryReturnsError() {
        let containsNoSearchParameter: OHHTTPStubsTestBlock = { request in
            if let url = request.url {
                let comps = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
                if let queryItems = comps?.queryItems {
                    return queryItems.filter({ qi in qi.name == "query" }).isEmpty
                }
            }
            return true
        }
        stub(condition: pathMatches(ContentRoute.searchMovies.rawValue) && containsNoSearchParameter) { _ in
            guard let stubPath = OHPathForFile("search_movie_no_query.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, status: 422, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "search movies request with no query returns error")

        contentService.request(.searchMovies) { (moviesDictionary, error) in
            XCTAssertNil(moviesDictionary)
            XCTAssertNotNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchMoviesRequestWithPageParameterButNoQueryReturnsError() {
        let containsNoSearchParameter: OHHTTPStubsTestBlock = { request in
            if let url = request.url {
                let comps = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
                if let queryItems = comps?.queryItems {
                    return queryItems.filter({ qi in qi.name == "query" }).isEmpty
                }
            }
            return true
        }
        let page = 2
        let parameters = ["page": String(page)]
        let condition = pathMatches(ContentRoute.searchMovies.rawValue)
            && containsQueryParams(parameters)
            && containsNoSearchParameter
        stub(condition: condition) { _ in
            guard let stubPath = OHPathForFile("search_movie_no_query.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, status: 422, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "search movies request with page parameter but no query returns error")

        contentService.request(.searchMovies, page: page) { (moviesDictionary, error) in
            XCTAssertNil(moviesDictionary)
            XCTAssertNotNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchMoviesRequestWithQueryParameterReturnsNonNilDictionary() {
        let query = "test"
        let parameters = ["query": query]
        stub(condition: pathMatches(ContentRoute.searchMovies.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("search_movie_query_test_page_1.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "search movies with query returns non-nil dictionary")

        contentService.request(.searchMovies, query: query) { (moviesDictionary, error) in
            XCTAssertNotNil(moviesDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchMoviesRequestWithPageAndQueryParametersReturnsNonNilDictionary() {
        let query = "test"
        let page = 2
        let parameters = ["query": query,
                          "page": String(page)]
        stub(condition: pathMatches(ContentRoute.searchMovies.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("search_movie_query_test_page_\(page).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "search movies with page and query returns non-nil dictionary")

        contentService.request(.searchMovies, query: query, page: page) { (moviesDictionary, error) in
            XCTAssertNotNil(moviesDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - Movie Genres Tests
extension ContentServiceTests {
    func testMovieGenresRequestReturnsNonNilDictionary() {
        stub(condition: pathMatches(ContentRoute.movieGenres.rawValue)) { _ in
            guard let stubPath = OHPathForFile("genre_movie_list.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie genres request successfully returns non-nil dictionary")

        contentService.request(.movieGenres) { (genresDictionary, error) in
            XCTAssertNotNil(genresDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieGenresRequestReturnsNonNilDictionaryIgnoringPageParameter() {
        let page = 3
        let parameters = ["page": String(page)]
        stub(condition: pathMatches(ContentRoute.movieGenres.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("genre_movie_list.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie genres returns non-nil dictionary ignoring page parameter")

        contentService.request(.movieGenres, page: page) { (genresDictionary, error) in
            XCTAssertNotNil(genresDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieGenresRequestReturnsNonNilDictionaryIgnoringQueryParameter() {
        let query = "test"
        let parameters = ["query": query]
        stub(condition: pathMatches(ContentRoute.movieGenres.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("genre_movie_list.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie genres returns non-nil dictionary ignoring query parameter")

        contentService.request(.movieGenres, query: query) { (genresDictionary, error) in
            XCTAssertNotNil(genresDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieGenresRequestReturnsNonNilDictionaryIgnoringPageAndQueryParameters() {
        let query = "test query"
        let page = 4
        let parameters = ["query": query,
                          "page": String(page)]
        stub(condition: pathMatches(ContentRoute.movieGenres.rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("genre_movie_list.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie genres returns non-nil dictionary ignoring parameters")

        contentService.request(.movieGenres, query: query, page: page) { (genresDictionary, error) in
            XCTAssertNotNil(genresDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - Movie Details Tests
extension ContentServiceTests {
    func testMovieRequestReturnsNonNilDictionary() {
        let movieID = 299536
        stub(condition: pathMatches(ContentRoute.movie(id: movieID).rawValue)) { _ in
            guard let stubPath = OHPathForFile("movie_\(movieID).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie id \(movieID) returns non-nil dictionary")

        contentService.request(.movie(id: movieID)) { (movieDictionary, error) in
            XCTAssertNotNil(movieDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieRequestReturnsNonNilDictionaryIgnoringPageParameter() {
        let movieID = 299536
        let page = 3
        let parameters = ["page": String(page)]
        stub(condition: pathMatches(ContentRoute.movie(id: movieID).rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("movie_\(movieID).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie id \(movieID) returns non-nil dictionary ignoring page parameter")

        contentService.request(.movie(id: movieID), page: page) { (movieDictionary, error) in
            XCTAssertNotNil(movieDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieRequestReturnsNonNilDictionaryIgnoringQueryParameter() {
        let movieID = 299536
        let query = "test"
        let parameters = ["query": query]
        stub(condition: pathMatches(ContentRoute.movie(id: movieID).rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("movie_\(movieID).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie id \(movieID) returns non-nil dictionary ignoring query parameter")

        contentService.request(.movie(id: movieID), query: query) { (movieDictionary, error) in
            XCTAssertNotNil(movieDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMovieRequestReturnsNonNilDictionaryIgnoringPageAndQueryParameters() {
        let movieID = 299536
        let query = "test query"
        let page = 4
        let parameters = ["query": query,
                          "page": String(page)]
        stub(condition: pathMatches(ContentRoute.movie(id: movieID).rawValue) && containsQueryParams(parameters)) { _ in
            guard let stubPath = OHPathForFile("movie_\(movieID).json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "movie id \(movieID) returns non-nil dictionary ignoring parameters")

        contentService.request(.movie(id: movieID), query: query, page: page) { (movieDictionary, error) in
            XCTAssertNotNil(movieDictionary)
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
