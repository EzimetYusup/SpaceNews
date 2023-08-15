//
//  Thunks.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/7/23.
//

import ReSwift
import ReSwiftThunk

let isRunningTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
let isUITest = ProcessInfo.processInfo.arguments.contains("isUITest")

let fetchArticle = Thunk<MainState> { dispatch, getState in

    guard
        let state = getState(),
        !state.articlePages.isComplete // check if we have fetched all the pages
    else {
        return
    }

    Task {
        let api = NewsApi()
        if !state.isTotalPageFetched { // check if we have fetched total # of page yet
            dispatch(fetchTotalArticleCount)
        }
        if state.articles.count == 0 && state.loadingState != .loading {
            // show loader if we are fetching first page
            dispatch(MainStateAction.showLoader)
        }
        let page = state.articlePages.currentPage + 1
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
                    dispatch(
                        MainStateAction.fetchedNews(articles: articles)
                    )
                }
            }
        case .failure(let failure):
            // we want fail silently if there are already news to show, only show error page when are fetching first page
            if state.articles.count == 0 {
                dispatch(MainStateAction.showError(failure.getUserFriendlyErrorMessage()))
            }
        }
//        if let articles = await api.fetchArticles(page: page) {
//            await MainActor.run {
//                if isRunningTest || isUITest {
//                    let testArticle = Article(id: 1, title: "NASA Awards Environmental Compliance, Operations Contract", url: "http://www.nasa.gov/press-release/nasa-awards-environmental-compliance-operations-contract", imageUrl: "https://www.nasa.gov/sites/default/files/thumbnails/image/nasa_meatball_1.jpeg?itok=hHt8a7fl", newsSite: "", summary: "NASA has selected Navarro Research and Engineering, Inc., of Oak Ridge, Tennessee, for the Environmental Compliance and Operations 3 (ECO3) contract, which provides environmental restoration program services and other support at the agency’s White Sands Test Facility in Las Cruces, New Mexico.", publishedAt: "")
//                        dispatch(
//                            MainStateAction.fetchedNews(articles: [testArticle])
//                        )
//                    return
//                }
//                dispatch(
//                    MainStateAction.fetchedNews(articles: articles)
//                )
//            }
//        } else {
//            if page == 1 {
//                dispatch(MainStateAction.showFailedStateView)
//            }
//        }
    }
}

let fetchTotalArticleCount = Thunk<MainState> { dispatch, _ in
    Task {
        print("loading total page")
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
