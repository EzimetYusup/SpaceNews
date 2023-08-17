//
//  News.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation

/// Article Model - Represents single news article from space news api v3
struct Article: Codable, Hashable, Equatable {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: String
}
