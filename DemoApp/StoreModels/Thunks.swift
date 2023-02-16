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
        !state.articlePages.isComplete
    else {
        return
    }

    Task {
        let api = NewsApi()
        if !state.isTotalPageFetched {
            dispatch(fetchTotalArticleCount)
        }
        let page = state.articlePages.currentPage + 1
        if let articles = await api.fetchArticles2(page: page) {
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
    }
}

let fetchTotalArticleCount = Thunk<MainState> { dispatch, _ in
    Task {
        print("loading total page")
        let count = await NewsApi().fetchTotalArticleCount2()
        if let count = count {
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
