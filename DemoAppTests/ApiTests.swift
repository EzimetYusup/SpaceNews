//
//  ApiTests.swift
//  DemoAppTests
//
//  Created by Ezimet Ozkhan on 8/15/23.
//

import XCTest
@testable import DemoApp

final class ApiTests: XCTestCase {
    let newsFirstPageUrl: String = "https://api.spaceflightnewsapi.net/v3/articles?_start=0"
    let totalCountUrl: String = "https://api.spaceflightnewsapi.net/v3/articles/count"
    var api: NewsApi!

    override func setUp() {
        super.setUp()
        api = NewsApi()
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
        URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.url = newsFirstPageUrl
        MockURLProtocol.statusCode = 400
        MockURLProtocol.result = .success(Data())
        let result = await api.fetchArticles(page: 1)
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .clientSideError)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }

    func testFetchArticleApi500Error() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        let api = NewsApi()
        MockURLProtocol.url = newsFirstPageUrl
        MockURLProtocol.statusCode = 500
        MockURLProtocol.result = .success(Data())
        let result = await api.fetchArticles(page: 1)
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .serverSideError)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }

    func testFetchWithInvalidURL() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)

        MockURLProtocol.url = newsFirstPageUrl
        MockURLProtocol.statusCode = 500
        MockURLProtocol.result = .success(Data())
        let result: Result<Article?, ApiError> = await api.fetch(url: "")
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .invalidRequest)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }

    func testFetchWithDecodingError() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.url = totalCountUrl
        MockURLProtocol.statusCode = 200
        let data = "string"
        MockURLProtocol.result = .success(data.description.data(using: .utf8))
        let result: Result<Int?, ApiError> = await api.fetch(url: totalCountUrl)
        if case .failure(let failure) = result {
            XCTAssertEqual(failure, .parsingError)
        } else {
            XCTAssert(false, "Should have failure")
        }
    }
}

protocol MockURLResponder {
    static func respond(to request: URLRequest) throws -> Data
}

class MockURLProtocol: URLProtocol {
    static var url: String = ""
    static var statusCode: Int = 200
    static var result: Result<Data?, Error>!

    override class func canInit(with request: URLRequest) -> Bool {
        if request.url?.absoluteString == url {
            return true
        }
        return false
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let client = client else { return }

        do {
            // Here we try to get data from our responder type, and
            // we then send that data, as well as a HTTP response,
            // to our client. If any of those operations fail,00000
            // we send an error instead:
//            let data = try Responder.respond(to: request)

            let response = try XCTUnwrap(HTTPURLResponse(
                url: XCTUnwrap(request.url),
                statusCode: Self.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            ))

            client.urlProtocol(self,
                               didReceive: response,
                               cacheStoragePolicy: .notAllowed
            )
            if case .success(let data) = Self.result, let data = data {
                client.urlProtocol(self, didLoad: data)
            }

            if case .failure(let error) = Self.result {
                client.urlProtocol(self, didFailWithError: error)
            }
            client.urlProtocolDidFinishLoading(self)

        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }

        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Required method, implement as a no-op.
    }
}
