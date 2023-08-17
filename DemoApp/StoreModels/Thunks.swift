//
//  Thunks.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import ReSwift
import ReSwiftThunk

/// a Thunk action - Fetches articles by page
let fetchArticle = Thunk<MainState> { dispatch, getState in
    guard
        let state = getState(),
        !state.articlePages.isComplete // check if we have fetched last page yet
    else {
        return
    }

    Task {
        let api = NewsApi()
        if !state.isTotalPageFetched { // check if we have fetched total # of page yet
            dispatch(fetchTotalArticleCount)
        }
        if state.articles.count == 0 && state.loadingState != .loading {
            // show loader, only if we are fetching first page
            dispatch(MainStateAction.showLoader)
        }
        // current page default value is 0 so need to add 1
        let page = state.articlePages.currentPage + 1
        // make async api call
        let result = await api.fetchArticles(page: page)
        switch result {
        case .success(let articles):
            if let articles = articles {
                await MainActor.run {
                    // dispatch fetchedNews action to notify reducer with newly fetched articles
                    dispatch(
                        MainStateAction.fetchedNews(articles: articles)
                    )
                }
            }
        case .failure(let failure):
            // we want to fail silently if there are already news to show
            // only show error page when fetching first page
            if state.articles.count == 0 {
                dispatch(MainStateAction.showError(failure.getUserFriendlyErrorMessage()))
            }
        }
    }
}

///  A Thunk - Fetches total # of article count action
let fetchTotalArticleCount = Thunk<MainState> { dispatch, _ in
    Task {
        print("fetching total # page")
        let result = await NewsApi().fetchTotalArticleCount()
        if case .success(let count) = result, let count = count {
            dispatch(
                MainStateAction.fetchedTotalArticleCount(totalCount: count)
            )
        }
    }
}

let isRunningTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
let isUITest = ProcessInfo.processInfo.arguments.contains("isUITest")
