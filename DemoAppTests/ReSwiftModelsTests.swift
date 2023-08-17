//
//  ReSwiftModelsTests.swift
//  DemoAppTests
//
//  Created by Ezimet Ozkhan on 2/14/23.
//

@testable import DemoApp
import XCTest
import ReSwift
import ReSwiftThunk

final class ReSwiftModelsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // register mocking url protocol to prevent making actual network call
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    /// Test initial state of main state
    func testInitialMainState() {
        let state = MainState()
        XCTAssertEqual(state.articles.count, 0)
        XCTAssertEqual(state.isTotalPageFetched, false)
        XCTAssertEqual(state.newsDetailStatus, .hide)
        XCTAssertEqual(state.articlePages.currentPage, 0)
        XCTAssertEqual(state.articlePages.totalPages, 1)
        XCTAssertEqual(state.articlePages.isComplete, false)
        XCTAssertEqual(state.loadingState, .idle)
    }

    func testFetchedTotalArticleCount() {
        // tests paging based on total count of articles and state.articlesPerPage = 10
        let action = MainStateAction.fetchedTotalArticleCount(totalCount: 15)
        let state = mainReducer(action: action, state: nil)
        XCTAssertEqual(state.articles.count, 0)
        XCTAssertEqual(state.isTotalPageFetched, true)
        XCTAssertEqual(state.articlePages.totalPages, 2)

        let action1 = MainStateAction.fetchedTotalArticleCount(totalCount: 9)
        let state1 = mainReducer(action: action1, state: nil)
        XCTAssertEqual(state1.articles.count, 0)
        XCTAssertEqual(state1.isTotalPageFetched, true)
        XCTAssertEqual(state1.articlePages.totalPages, 1)

        let action2 = MainStateAction.fetchedTotalArticleCount(totalCount: 10)
        let state2 = mainReducer(action: action2, state: nil)
        XCTAssertEqual(state2.articles.count, 0)
        XCTAssertEqual(state2.isTotalPageFetched, true)
        XCTAssertEqual(state2.articlePages.totalPages, 1)

        let action3 = MainStateAction.fetchedTotalArticleCount(totalCount: 39)
        let state3 = mainReducer(action: action3, state: nil)
        XCTAssertEqual(state3.articles.count, 0)
        XCTAssertEqual(state3.isTotalPageFetched, true)
        XCTAssertEqual(state3.articlePages.totalPages, 4)
    }

    func testNewsDetailStatus() {
        // test show article detail action
        let article = Article(id: 1, title: "title 1", url: "url1", imageUrl: "imageurl1",
                              newsSite: "newsSite1", summary: "summary1", publishedAt: "today1")
        let action = MainStateAction.didTapArticle(article)
        let state = mainReducer(action: action, state: nil)
        XCTAssertEqual(state.newsDetailStatus, .show(article))

        // test hide article detail action
        let action1 = MainStateAction.willHide(article)
        let state1 = mainReducer(action: action1, state: state)
        XCTAssertEqual(state1.newsDetailStatus, .willHide(article))

        let action2 = MainStateAction.hideNewsDetail
        let state2 = mainReducer(action: action2, state: state1)
        XCTAssertEqual(state2.newsDetailStatus, .hide)
    }

    func testShowLoaderAction() {
        let action = MainStateAction.showLoader
        let initialState = MainState()
        XCTAssertEqual(initialState.loadingState, .idle)
        let newState = mainReducer(action: action, state: initialState)
        XCTAssertEqual(newState.loadingState, .loading)
    }

    func testShowErrorAction() {
        let errorMessage = "Oh Snap!"
        let action = MainStateAction.showError(errorMessage)
        let initialState = MainState()
        XCTAssertEqual(initialState.loadingState, .idle)
        let newState = mainReducer(action: action, state: initialState)
        XCTAssertEqual(newState.loadingState, .failed(errorMessage))
    }

    func testFetchedNewsAction() {
        var initialState = MainState()
        initialState.loadingState = .loading
        let action0 = MainStateAction.fetchedTotalArticleCount(totalCount: 19)
        let newState0 = mainReducer(action: action0, state: initialState)
        XCTAssertEqual(newState0.articles.count, 0)
        XCTAssertEqual(newState0.isTotalPageFetched, true)
        XCTAssertEqual(newState0.articlePages.totalPages, 2)
        XCTAssertEqual(newState0.loadingState, .loading)

        let articles = getRandomMockArticles()
        let action = MainStateAction.fetchedNews(articles: articles)
        let newState1 = mainReducer(action: action, state: newState0)
        XCTAssertEqual(newState1.articles, articles)
        XCTAssertEqual(newState1.articlePages.currentPage, 1)
        XCTAssertEqual(newState1.articlePages.isComplete, false)
        XCTAssertEqual(newState1.loadingState, .idle)

        let articles2 = getRandomMockArticles()
        let action1 = MainStateAction.fetchedNews(articles: articles2)
        let newState2 = mainReducer(action: action1, state: newState1)
        XCTAssertEqual(newState2.articles.count, articles.count + articles2.count)
        XCTAssertEqual(newState2.articles, articles + articles2)
        XCTAssertEqual(newState2.articlePages.currentPage, 2)
        XCTAssertEqual(newState2.articlePages.isComplete, true)
        XCTAssertEqual(newState2.loadingState, .idle)
    }

    // MARK: Test Thunks
    func testFetchTotalArticleCountThunksHappyPath() {
        let mockCount = 5
        MockURLProtocol.setMockResponse(for: "https://api.spaceflightnewsapi.net/v3/articles/count", statusCode: 200, result: .success(mockCount.description.data(using: .utf8)))
        let expectThunk = ExpectThunk(fetchTotalArticleCount)
            .dispatches(MainStateAction.fetchedTotalArticleCount(totalCount: mockCount))
            .wait()
        XCTAssertEqual(expectThunk.dispatched.count, 1)
    }

    func testFetchArticleThunksFinishedAllPage() {
        // when we reached total pages, it should not dispatch any action
        var state = MainState()
        state.isTotalPageFetched = true
        state.articlePages.totalPages = 0
        let expectThunk = ExpectThunk(fetchArticle)
            .getsState(state)
            .run()
        XCTAssertEqual(expectThunk.dispatched.count, 0)
    }

    func testFetchArticleThunksHappyPath() {
        var state = MainState()
        let mockCount = 5
        let mockArticles = Article(id: 1, title: "NASA Awards Environmental Compliance, Operations Contract",
                                   url: "http://www.nasa.gov/press-release/nasa-awards-environmental-compliance-operations-contract",
                                   imageUrl: "https://www.nasa.gov/sites/default/files/thumbnails/image/nasa_meatball_1.jpeg?itok=hHt8a7fl",
                                   newsSite: "",
                                   summary: "NASA has selected Navarro Research and Engineering, Inc., of Oak Ridge, Tennessee, for the Environmental Compliance and Operations 3 (ECO3) contract, which provides environmental restoration program services and other support at the agency’s White Sands Test Facility in Las Cruces, New Mexico.", publishedAt: "")
        let jsonEncoder = JSONEncoder()
        let jsonResultData = try? jsonEncoder.encode([mockArticles])
        MockURLProtocol.setMockResponse(for: ApiTests.totalCountUrl, statusCode: 200, result: .success(mockCount.description.data(using: .utf8)))
        MockURLProtocol.setMockResponse(for: ApiTests.newsFirstPageUrl, statusCode: 200, result: .success(jsonResultData))
        state.isTotalPageFetched = true
        let expectThunk = ExpectThunk(fetchArticle)
            .getsState(state)
            .dispatches(MainStateAction.showLoader)
            .dispatches(MainStateAction.fetchedNews(articles: [mockArticles]))
            .wait()
        XCTAssertEqual(expectThunk.dispatched.count, 2)
    }

    func testFetchArticleThunksFailureWithBadInternetConnection() {
        var state = MainState()
        MockURLProtocol.setMockResponse(for: ApiTests.newsFirstPageUrl, statusCode: nil, result: .failure(URLError.init(URLError.notConnectedToInternet)))
        state.isTotalPageFetched = true
        let expectThunk = ExpectThunk(fetchArticle)
            .getsState(state)
            .dispatches(MainStateAction.showLoader)
            .dispatches(MainStateAction.showError(ApiError.badInternetConnection.getUserFriendlyErrorMessage()))
            .wait()
        XCTAssertEqual(expectThunk.dispatched.count, 2)
    }

    func getRandomMockArticles() -> [Article] {
        var articles: [Article] = []
        for index in 0...Int.random(in: 1..<5) {
            let uuid = UUID()
            let article = Article(id: index, title: "title \(uuid)", url: "url\(uuid)", imageUrl: "imageurl\(uuid)",
                    newsSite: "newsSite\(uuid)", summary: "summary\(uuid)", publishedAt: "today\(uuid)")
            articles.append(article)
        }
        return articles
    }
}
