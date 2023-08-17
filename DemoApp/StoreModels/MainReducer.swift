//
//  MainReducer.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/9/23.
//

import Foundation
import ReSwift

/// MainReducer of the App - May change state depending on different actions
/// - Parameters:
///   - action: Action should be subclass of MainStateAction
///   - state: MainState
/// - Returns: New mutated MainState
func mainReducer(action: Action, state: MainState?) -> MainState {
    var state = state ?? MainState()

    guard let action = action as? MainStateAction else {
        return state
    }
    switch action {
    case .showLoader:
        // change loading state to loading
        state.loadingState = .loading
    case .fetchedNews(let articles):
        // hide the loader and add the fetched articles to pages model
        state.loadingState = .idle
        state.articlePages.addPage(values: articles)
    case .fetchedTotalArticleCount(let totalCount):
        // store the total # pages and mark the flag to true to prevent it from making same second api call
        state.articlePages.totalPages = Int(ceil(Double(totalCount)/Double(state.articlesPerPage)))
        state.isTotalPageFetched = true
    case .didTapArticle(let article):
        // did tap article, change the state of details screen to push the news details screen to navigation stack
        state.newsDetailStatus = .show(article)
    case .hideNewsDetail:
        // change the news details status, pop the news details screen from navigation stack
        state.newsDetailStatus = .hide
    case .willHide(let article):
        // change the news details status that news details will pop soon
        state.newsDetailStatus = .willHide(article)
    case .showError(let errorMessage):
        // change the loading state, show error screen
        state.loadingState = .failed(errorMessage)
    }
    return state
}
