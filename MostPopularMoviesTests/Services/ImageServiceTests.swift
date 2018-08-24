//
//  ImageServiceTests.swift
//  MostPopularMoviesTests
//
//  Created by Alex Magalhaes on 08/23/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

@testable import MostPopularMovies
import OHHTTPStubs
import XCTest

class ImageServiceTests: XCTestCase {
    private let imageService: ImageServiceProtocol = ImageService()
    private let mockHost = "image.service.test"

    override func setUp() {
        super.setUp()
        stub(condition: isHost(mockHost)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "image/jpeg"])
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testImageRequestReturnsNonNilResponseData() {
        let expect = expectation(description: "image request returns non-nil data")

        let imagePath = "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"
        imageService.requestImage("https://\(mockHost)\(imagePath)") { data in
            XCTAssertNotNil(data)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testImageRequestWithNilURLReturnsNilResponseData() {
        let expect = expectation(description: "image request with nil url returns nil data")

        imageService.requestImage(nil) { data in
            XCTAssertNil(data)
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
