//
//  MockURLProtocol.swift
//  DemoAppTests
//
//  Created by Ezimet Ozkhan on 8/17/23.
//

import Foundation
import XCTest

/// MockURLProtocol - used for rewriting and mocking HTTP requests
class MockURLProtocol: URLProtocol {

    /// URL to rewrite in unit tests
    private static var url: String = ""
    /// Mock status code of HTTP response
    private static var statusCode: Int = 200
    /// Mock Result of HTTP request
    private static var result: Result<Data?, Error>!

    /// Sets mock response for given url
    /// - Parameters:
    ///   - url: String URL of request being mocked
    ///   - statusCode: Int mocked HTTP Response
    ///   - result: Result<Data?, Error> being mocked
    class func setMockResponse(for url: String, statusCode: Int, result: Result<Data?, Error>) {
        Self.url = url
        Self.statusCode = statusCode
        Self.result = result
    }

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
