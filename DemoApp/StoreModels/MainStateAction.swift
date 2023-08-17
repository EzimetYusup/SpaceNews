//
//  MainStateAction.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/6/23.
//

import ReSwift

/// MainStateAction - includes actions that mainly interacts with NewsList Screen
enum MainStateAction: Action, Equatable {
    ///  action to show news detail screen
    case didTapArticle(_ article: Article)
    case hideNewsDetail
    /// action to show loader
    case showLoader
    /// action to show error screen when failed to fetch first page of news list
    case showError(String?)
    /// action
    case willHide(Article)
    /// action to populate articles pages after successfully fetched them
    case fetchedNews(articles: [Article])
    /// action to store total # of articles to state
    case fetchedTotalArticleCount(totalCount: Int)
}
