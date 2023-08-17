//
//  Api.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/6/23.
//

import Foundation

/// Api Client for space news api
struct NewsApi {
    // space news base url
    let baseUrl = "https://api.spaceflightnewsapi.net/v3/"

    /// Fetch space news articles by page
    /// - Parameter page: Int, page to request, 10 articles per page
    /// - Returns: result with array of articles or ApiError
    func fetchArticles(page: Int)  async -> Result<[Article]?, ApiError> {
        await fetch(url: "\(baseUrl)articles?_start=\((page-1)*10)")
    }

    func fetchTotalArticleCount() async -> Result<Int?, ApiError> {
        await fetch(url: "\(baseUrl)articles/count")
    }

    /// Generic Get method, will make a GET request and tries to decode the json to model
    /// - Parameter url: String of GET request
    /// - Returns: Result with decoded model or ApiError
    func fetch<T: Codable>(url: String) async -> Result<T?, ApiError> {
        guard let url = URL(string: url) else {
            return .failure(.invalidRequest)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                // categorize all 400 errors as client side error
                if (400...499).contains(httpResponse.statusCode) {
                    return .failure(.clientSideError)
                }
                // categories all 500 errors as server side error
                if (500...599).contains(httpResponse.statusCode) {
                    return .failure(.serverSideError)
                }
            }
            // decode the raw data to model
            let obj = try JSONDecoder().decode(T.self, from: data)
            return .success(obj)
            // catches parsing errors
        } catch _ as DecodingError {
            return .failure(.parsingError)
        } catch {
            // all other errors
            return .failure(ApiError(error as? URLError))
        }
    }
}
