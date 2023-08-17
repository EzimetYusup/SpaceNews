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
        // make async call
        let result = await api.fetchArticles(page: page)
        switch result {
        case .success(let articles):
            if let articles = articles {
                await MainActor.run {
                    if isRunningTest || isUITest {
                        let testArticle = Article(id: 1, title: "NASA Awards Environmental Compliance, Operations Contract", url: "http://www.nasa.gov/press-release/nasa-awards-environmental-compliance-operations-contract", imageUrl: "https://www.nasa.gov/sites/default/files/thumbnails/image/nasa_meatball_1.jpeg?itok=hHt8a7fl", newsSite: "", summary: "NASA has selected Navarro Research and Engineering, Inc., of Oak Ridge, Tennessee, for the Environmental Compliance and Operations 3 (ECO3) contract, which provides environmental restoration program services and other support at the agency’s White Sands Test Facility in Las Cruces, New Mexico.", publishedAt: "")
                        dispatch(
                            MainStateAction.fetchedNews(articles: [testArticle])
                        )
                        return
                    }
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
            if isRunningTest || isUITest {
                dispatch(
                    MainStateAction.fetchedTotalArticleCount(totalCount: 5)
                )
                return
            }

            dispatch(
                MainStateAction.fetchedTotalArticleCount(totalCount: count)
            )
        }
    }
}

let isRunningTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
let isUITest = ProcessInfo.processInfo.arguments.contains("isUITest")
