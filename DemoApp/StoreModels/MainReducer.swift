//
//  MainReducer.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/9/23.
//

import Foundation
import ReSwift

func mainReducer(action: Action, state: MainState?) -> MainState {
    var state = state ?? MainState()

    guard let action = action as? MainStateAction else {
        return state
    }
    switch action {
    case .fetchedNews(let articles):
        state.articlePages.addPage(values: articles)
    case .fetchedTotalArticleCount(let totalCount):
        state.articlePages.totalPages = Int(ceil(Double(totalCount)/Double(state.articlesPerPage)))
        state.isTotalPageFetched = true
    case .didTapArticle(let article):
        state.newsDetailStatus = .show(article)
    case .hideNewsDetail:
        state.newsDetailStatus = .hide
    case .willHide(let article):
        state.newsDetailStatus = .willHide(article)
    }
    return state
}
