//
//  ApiError.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 8/16/23.
//

import Foundation

/// Api Error enum - represents common network errors  and deserialization errors and their user friendly error messages
enum ApiError: Error {
    init(_ error: Error? = nil) {
        if let error = error as? URLError, error.code == .notConnectedToInternet || error.code == .timedOut {
            self = .badInternetConnection
            return
        }
        self = .unknown
    }
    /// invalid request - bad url etc
    case invalidRequest
    /// no internet connection or time out errors in bad internet connection
    case badInternetConnection
    /// server side 500 - 599 status code errors
    case serverSideError
    /// client side 400-499 status code errors
    case clientSideError
    /// deserialization error while decoding raw json to models
    case parsingError
    /// all other errors
    case unknown

    /// User friendly error messages of each Api error
    /// - Returns: String
    func getUserFriendlyErrorMessage() -> String {
        switch self {
        case .badInternetConnection:
            return "Looks like your internet connection is offline, please try again later"
        case .serverSideError:
            return "Oh snap! looks like we need to fix something on our server"
        case .clientSideError, .invalidRequest, .parsingError, .unknown:
            return "Oh snap! looks like something went wrong"
        }
    }
}
