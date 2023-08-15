//
//  MainState.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import Foundation
import ReSwift
import ReSwiftThunk

// MARK: DetailScreenState
enum NewsDetailStatus: Equatable {
    case willHide(Article)
    case hide
    case show(Article)

    var article: Article? {
        switch self {
        case .show(let article):
            return article
        case .hide:
            return nil
        case .willHide(let article):
            return article
        }
    }

}

enum LoadingState: Equatable {
    case idle
    case loading
    case failed(String?)
}

// MARK: App State
struct MainState: Equatable {
    var loadingState: LoadingState = .idle
    var articlesPerPage = 10
    var isTotalPageFetched = false
    var articlePages: Pages<Article> = Pages<Article>()
    var newsDetailStatus: NewsDetailStatus = .hide
    var articles: [Article] {
        return articlePages.values.uniqued()
    }
}

let thunksMiddleware: Middleware<MainState> = createThunkMiddleware()

let mainStore = Store(
    reducer: mainReducer,
    state: MainState(),
    middleware: [thunksMiddleware]
)
