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

    func fetch<T: Codable>(url: String) async -> Result<T?, ApiError> {
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
        } catch _ as DecodingError {
            return .failure(.parsingError)
        } catch {
            return .failure(ApiError(error as? URLError))
        }
    }
}
