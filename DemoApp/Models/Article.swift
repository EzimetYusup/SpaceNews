//
//  News.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation

/// Article Model - Represents single news article from space news api v3
struct Article: Codable, Hashable, Equatable {
    /// unique id of the news article
    let id: Int
    /// title of news article
    let title: String
    /// original url of news article
    let url: String
    /// main image of news article
    let imageUrl: String
    /// original news site name
    let newsSite: String
    /// summary of news article
    let summary: String
    /// published date of news article
    let publishedAt: String
}
