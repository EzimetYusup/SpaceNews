//
//  MainState.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation
import ReSwift
import ReSwiftThunk

// MARK: App State
/// Main state - main state of news list and details screens
struct MainState: Equatable {
    /// loading state of news list screen
    var loadingState: LoadingState = .idle
    /// smallest unit for pagination
    let articlesPerPage = 10
    /// indicates if we have fetched total # of pages
    var isTotalPageFetched = false
    /// article pages holds page information and articles
    var articlePages: Pages<Article> = Pages<Article>()
    /// news details screen status
    var newsDetailStatus: NewsDetailStatus = .hide
    /// currently fetched articles
    var articles: [Article] {
        return articlePages.values.uniqued()
    }
}

// MARK: DetailScreenState
/// NewsDetailStatus - represents various status of news details screen
enum NewsDetailStatus: Equatable {
    /// indicates NewsDetails screen will disappear
    case willHide(Article)
    /// default status of news details screen
    case hide
    /// indicates news details screen will show given article
    case show(Article)
}

/// Loading state of a screen
enum LoadingState: Equatable {
    /// default state
    case idle
    /// loading state
    case loading
    /// indicates an error happen
    case failed(String?)
}

/// thunks middleware - for supporting asynchronous  running actions
let thunksMiddleware: Middleware<MainState> = createThunkMiddleware()

/// global ReSwift main store for the app
let mainStore = Store(
    reducer: mainReducer,
    state: MainState(),
    middleware: [thunksMiddleware]
)
