//
//  MockURLProtocol.swift
//  DemoAppTests
//
//  Created by Ezimet Ozkhan on 8/17/23.
//

import Foundation

/// MockURLProtocol - used for mocking HTTP responses
class MockURLProtocol: URLProtocol {
    /// key is  URL to rewrite in mocking, value is tuple of (Mock HTTP response status code, Mock Result<Data, Error>)
    private static var mockResponder: [String: (Int?, Result<Data?, Error>)] = [:]

    /// Sets mock response for given url
    /// - Parameters:
    ///   - url: String URL of request being mocked
    ///   - statusCode: Int mocked HTTP Response
    ///   - result: Result<Data?, Error> being mocked
    class func setMockResponse(for url: String, statusCode: Int?, result: Result<Data?, Error>) {
        let respond = (statusCode, result)
        Self.mockResponder[url] = respond
    }

    /// no  ned implementation details since we are just using for mocking
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    /// decides whether we want to mock this request or not
    /// - Parameter request: URLRequest
    /// - Returns: Bool
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url?.absoluteString else { return false }
        if mockResponder[url] != nil {
            return true
        }
        return false
    }

    /// Mocks the response
    override func startLoading() {
        guard let client = client, let url = request.url, let (statusCode, result) = Self.mockResponder[url.absoluteString] else { return }
        defer {
            client.urlProtocolDidFinishLoading(self)
        }

        if case .failure(let error) = result {
            client.urlProtocol(self, didFailWithError: error)
            return
        }
        // mock HTTP response
        if let response = HTTPURLResponse(url: url, statusCode: statusCode ?? 200, httpVersion: "HTTP/1.1", headerFields: nil) {
            client.urlProtocol(self,
                                didReceive: response,
                                cacheStoragePolicy: .notAllowed
            )
        }

        if case .success(let data) = result, let data = data {
            client.urlProtocol(self, didLoad: data)
        }

    }

    /// no  ned implementation details since we are just mocking, and it's pretty much instant
    override func stopLoading() {
        // stop loading
    }
}
