//
//  Api.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/6/23.
//

import Foundation

class NewsApi {

    let baseUrl = "https://api.spaceflightnewsapi.net/v3/"

    func fetchArticles(page: Int, completion: @escaping ([Article]?) -> Void) {
        fetch(
            url: "\(baseUrl)articles?_start=\((page-1)*10)",
            completion: completion
        )
    }

    func fetchArticles2(page: Int)  async -> [Article]? {
        await fetch2(url: "\(baseUrl)articles?_start=\((page-1)*10)")
    }

    func fetchTotalArticleCount(completion: @escaping (Int?) -> Void) {
        fetch(
            url: "\(baseUrl)articles/count",
            completion: completion
        )
    }

    func fetchTotalArticleCount2() async -> Int? {
        await fetch2(url: "\(baseUrl)articles/count")
    }

    func fetch2<T: Codable>(url: String) async -> T? {
        guard let url = URL(string: url) else {
            print("url is nil")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let obj = try? JSONDecoder().decode(T.self, from: data)
            if obj == nil {

                print("object \(String(describing: T.self)) is nil")
            }
            return obj
        } catch {
            print("Error info: \(error)")
        }
        return nil
    }

    func fetch<T: Codable>(url: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: url) else { return completion(nil) }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard
                let data = data,
                let obj = try? JSONDecoder().decode(T.self, from: data)
            else {
                return completion(nil)
            }

            completion(obj)
        }

        task.resume()
    }
}
