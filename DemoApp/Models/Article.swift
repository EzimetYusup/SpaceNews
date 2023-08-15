//
//  News.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation

struct Article: Codable, Hashable, Equatable {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: String

    func isContentEqual(to source: Article) -> Bool {
        return self.id == source.id
    }
}
