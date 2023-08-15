//
//  MainStateAction.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/6/23.
//

import ReSwift

enum MainStateAction: Action, Equatable {
    case didTapArticle(_ article: Article)
    case hideNewsDetail
    case showLoader
    case retry
    case showError(String?)
    case willHide(Article)
    case fetchedNews(articles: [Article])
    case fetchedTotalArticleCount(totalCount: Int)
}
