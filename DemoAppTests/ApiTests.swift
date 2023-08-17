//
//  ApiTests.swift
//  DemoAppTests
//
//  Created by Ezimet Ozkhan on 8/15/23.
//

import XCTest
@testable import DemoApp

final class ApiTests: XCTestCase {
    static let newsFirstPageUrl: String = "https://api.spaceflightnewsapi.net/v3/articles?_start=0"
    static let totalCountUrl: String = "https://api.spaceflightnewsapi.net/v3/articles/count"
    var api: NewsApi!

    override func setUp() {
        super.setUp()
        api = NewsApi()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    func testApiErrorUserFriendlyErrorMessages() throws {
        let somethingWentWrongMessage = "Oh snap! looks like something went wrong"
        let somethingWrongOnServer = "Oh snap! looks like we need to fix something on our server"
        let youAreOffline = "Looks like your internet connection is offline, please try again later"
        let errors: [ApiError] = [.clientSideError, .invalidRequest, .parsingError, .unknown]
        errors.forEach { XCTAssertEqual($0.getUserFriendlyErrorMessage(), somethingWentWrongMessage) }
        XCTAssertEqual(ApiError.badInternetConnection.getUserFriendlyErrorMessage(), youAreOffline)
        XCTAssertEqual(ApiError.serverSideError.getUserFriendlyErrorMessage(), somethingWrongOnServer)
    }

    func testApiErrorInit() throws {
        let connectionError = URLError(.notConnectedToInternet)
        let apiError = ApiError(connectionError)
        XCTAssertEqual(apiError, .badInternetConnection)

        let timeOutError = URLError(.timedOut)
        let apiError2 = ApiError(timeOutError)
        XCTAssertEqual(apiError2, .badInternetConnection)

        let unknownError = ApiError()
        XCTAssertEqual(unknownError, .unknown)
    }

    func testFetchArticleApi400Error() async throws {
        MockURLProtocol.setMockResponse(for: Self.newsFirstPageUrl, statusCode: 400, result: .success(Data()))
        let result = await api.fetchArticles(page: 1)
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .clientSideError)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }

    func testFetchArticleApi500Error() async throws {
        MockURLProtocol.setMockResponse(for: Self.newsFirstPageUrl, statusCode: 500, result: .success(Data()))
        let result = await api.fetchArticles(page: 1)
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .serverSideError)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }

    func testFetchWithInvalidURL() async throws {
        let result: Result<Article?, ApiError> = await api.fetch(url: "")
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .invalidRequest)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }

    func testFetchWithDecodingError() async throws {
        let data = "string"
        MockURLProtocol.setMockResponse(for: Self.newsFirstPageUrl, statusCode: 200, result: .success(data.description.data(using: .utf8)))
        let result: Result<Int?, ApiError> = await api.fetch(url: Self.newsFirstPageUrl)
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .parsingError)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }
}
