//
//  ImagesRepositoryTests.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/24/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import OHHTTPStubs
import XCTest

class ImagesRepositoryTests: XCTestCase {
    private let imagesRepository: ImagesRepositoryProtocol = ImagesRepository()
    private let imagesHost = "image.tmdb.org"
    private let imagePath = "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testLoadConfigurationCompletionBlockIsCalledOnSuccess() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        let expect = expectation(description: "load configuration completion block is called on success")

        imagesRepository.loadConfiguration {
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadConfigurationCompletionBlockIsCalledOnFailure() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            return OHHTTPStubsResponse(jsonObject: [:], statusCode: 404, headers: nil)
        }

        let expect = expectation(description: "load configuration completion block is called on failure")

        imagesRepository.loadConfiguration {
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadBackdropImageCompletionBlockIsCalledWithNonNilData() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost(imagesHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }

        let expect = expectation(description: "load backdrop image block is called with data")

        imagesRepository.loadConfiguration { [unowned self] in
            self.imagesRepository.loadBackdropImage(self.imagePath, width: 500, completion: { data in
                XCTAssertNotNil(data)
                expect.fulfill()
            })
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadBackdropImageWithNoURLCompletionBlockIsCalledWithNilData() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost(imagesHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }

        let expect = expectation(description: "load backdrop image with no url, block is called with no data")

        imagesRepository.loadConfiguration { [unowned self] in
            self.imagesRepository.loadBackdropImage(nil, width: 500, completion: { data in
                XCTAssertNil(data)
                expect.fulfill()
            })
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadBackdropImageWithNoConfigurationCompletionBlockIsCalledWithNilData() {
        stub(condition: isHost(imagesHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }

        let expect = expectation(description: "load backdrop image with no configuration, block with no data")

        imagesRepository.loadBackdropImage(imagePath, width: 500, completion: { data in
            XCTAssertNil(data)
            expect.fulfill()
        })

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadPosterImageCompletionBlockIsCalledWithNonNilData() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost(imagesHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }

        let expect = expectation(description: "load poster image block is called with data")

        imagesRepository.loadConfiguration { [unowned self] in
            self.imagesRepository.loadPosterImage(self.imagePath, width: 500, completion: { data in
                XCTAssertNotNil(data)
                expect.fulfill()
            })
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadPosterImageWithNoURLCompletionBlockIsCalledWithNilData() {
        stub(condition: pathMatches(ContentRoute.configuration.rawValue)) { _ in
            guard let stubPath = OHPathForFile("configuration.json", type(of: self)) else {
                return OHHTTPStubsResponse(error: ContentServiceTestsError.noPathForStub)
            }
            return fixture(filePath: stubPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost(imagesHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }

        let expect = expectation(description: "load poster image with no url, block is called with no data")

        imagesRepository.loadConfiguration { [unowned self] in
            self.imagesRepository.loadPosterImage(nil, width: 500, completion: { data in
                XCTAssertNil(data)
                expect.fulfill()
            })
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadPosterImageWithNoConfigurationCompletionBlockIsCalledWithNilData() {
        stub(condition: isHost(imagesHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }

        let expect = expectation(description: "load poster image with no configuration, block with no data")

        imagesRepository.loadPosterImage(imagePath, width: 500, completion: { data in
            XCTAssertNil(data)
            expect.fulfill()
        })

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
