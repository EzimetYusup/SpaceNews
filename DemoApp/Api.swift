//
//  Api.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/6/23.
//

import Foundation

class NewsApi {

    let baseUrl = "https://api.spaceflightnewsapi.net/v3/"

    func fetchArticles(page: Int)  async -> Result<[Article]?, ApiError> {
        await fetch(url: "\(baseUrl)articles?_start=\((page-1)*10)")
    }

    func fetchTotalArticleCount() async -> Result<Int?, ApiError> {
        await fetch(url: "\(baseUrl)articles/count")
    }

    private func fetch<T: Codable>(url: String) async -> Result<T?, ApiError> {
        guard let url = URL(string: url) else {
            return .failure(.invalidRequest)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                if (400...499).contains(httpResponse.statusCode) {
                    return .failure(.clientSideError)
                }

                if (500...599).contains(httpResponse.statusCode) {
                    return .failure(.serverSideError)
                }
            }

            let obj = try JSONDecoder().decode(T.self, from: data)
            return .success(obj)
        } catch {
            print("Error info: \(error)")
            return .failure(ApiError(error as? URLError))
        }
    }
}

enum ApiError: Error {
    init(_ error: Error?) {
        if let error = error as? URLError, error.code == .notConnectedToInternet || error.code == .timedOut {
            self = .badInternetConnection
            return
        }
        if error as? DecodingError != nil {
            self = .parsingError
            return
        }
        self = .unknown
    }
    case invalidRequest
    case badInternetConnection
    case serverSideError
    case clientSideError
    case parsingError
    case unknown

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
