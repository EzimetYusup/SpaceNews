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

    func testInitialMainState() {
        let state = MainState()
        XCTAssertEqual(state.articles.count, 0)
        XCTAssertEqual(state.isTotalPageFetched, false)
        XCTAssertEqual(state.newsDetailStatus, .hide)
        XCTAssertEqual(state.articlePages.currentPage, 0)
        XCTAssertEqual(state.articlePages.totalPages, 1)
        XCTAssertEqual(state.articlePages.isComplete, false)
    }

    func testfetchedTotalArticleCount() {
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
        let article = Article(id: 1, title: "title 1", url: "url1", imageUrl: "imageurl1",
                              newsSite: "newsSite1", summary: "summary1", publishedAt: "today1")
        let action = MainStateAction.didTapArticle(article)
        let state = mainReducer(action: action, state: nil)
        XCTAssertEqual(state.newsDetailStatus, .show(article))

        let action1 = MainStateAction.willHide(article)
        let state1 = mainReducer(action: action1, state: state)
        XCTAssertEqual(state1.newsDetailStatus, .willHide(article))

        let action2 = MainStateAction.hideNewsDetail
        let state2 = mainReducer(action: action2, state: state1)
        XCTAssertEqual(state2.newsDetailStatus, .hide)
    }

    func testFetchedNewsAction() {
        let action0 = MainStateAction.fetchedTotalArticleCount(totalCount: 19)
        let state0 = mainReducer(action: action0, state: nil)
        XCTAssertEqual(state0.articles.count, 0)
        XCTAssertEqual(state0.isTotalPageFetched, true)
        XCTAssertEqual(state0.articlePages.totalPages, 2)

        let articles = [Article(id: 1, title: "title 1", url: "url1", imageUrl: "imageurl1",
                                newsSite: "newsSite1", summary: "summary1", publishedAt: "today1"),
                        Article(id: 2, title: "title 2", url: "url2", imageUrl: "imageurl2",
                                newsSite: "newsSite2", summary: "summary2", publishedAt: "today2")]
        let action = MainStateAction.fetchedNews(articles: articles)
        let state = mainReducer(action: action, state: state0)
        XCTAssertEqual(state.articles.count, 2)
        XCTAssertEqual(state.articles, articles)
        XCTAssertEqual(state.articlePages.currentPage, 1)
        XCTAssertEqual(state.articlePages.isComplete, false)

        let articles2 = [Article(id: 3, title: "title 3", url: "url3", imageUrl: "imageurl3", newsSite: "newsSite1", summary: "summary1", publishedAt: "today1"),
                        Article(id: 4, title: "title 2", url: "url2", imageUrl: "imageurl2", newsSite: "newsSite2", summary: "summary2", publishedAt: "today2")]
        let action1 = MainStateAction.fetchedNews(articles: articles2)
        let newState = mainReducer(action: action1, state: state)
        XCTAssertEqual(newState.articles.count, 4)
        XCTAssertEqual(newState.articles, articles + articles2)
        XCTAssertEqual(newState.articlePages.currentPage, 2)
        XCTAssertEqual(newState.articlePages.isComplete, true)
    }

    func testFetchTotalArticleCountThunks() {
        let expectThunk = ExpectThunk(fetchTotalArticleCount)

            .dispatches(dispatch: { action in
                let realAction = action as? MainStateAction
                XCTAssert(action is MainStateAction)
                XCTAssertEqual(realAction, MainStateAction.fetchedTotalArticleCount(totalCount: 5))
            }).wait()
        XCTAssertEqual(expectThunk.dispatched.count, 1)
    }

    func testFetchArticleThunks() {
        var state = MainState()
        state.isTotalPageFetched = true
        let expectThunk = ExpectThunk(fetchArticle)
            .getsState(state)
            .dispatches(dispatch: { action in
                let realAction = action as? MainStateAction
                XCTAssert(action is MainStateAction)
                let article = Article(id: 1, title: "NASA Awards Environmental Compliance, Operations Contract",
                                      url: "http://www.nasa.gov/press-release/nasa-awards-environmental-compliance-operations-contract",
                                      imageUrl: "https://www.nasa.gov/sites/default/files/thumbnails/image/nasa_meatball_1.jpeg?itok=hHt8a7fl",
                                      newsSite: "",
                                      summary: "NASA has selected Navarro Research and Engineering, Inc., of Oak Ridge, Tennessee, for the Environmental Compliance and Operations 3 (ECO3) contract, which provides environmental restoration program services and other support at the agency’s White Sands Test Facility in Las Cruces, New Mexico.", publishedAt: "")
                if case .fetchedNews(let article1) =  realAction {
                    XCTAssert(true)
                    XCTAssertEqual(article1, [article])
                }

            }).wait()
        XCTAssertEqual(expectThunk.dispatched.count, 1)
    }
}

// pod 'ReSwiftThunk/ExpectThunk'
private struct ExpectThunkAssertion<T> {
    fileprivate let associated: T
    private let description: String
    private let file: StaticString
    private let line: UInt

    init(description: String, file: StaticString, line: UInt, associated: T) {
        self.associated = associated
        self.description = description
        self.file = file
        self.line = line
    }

    fileprivate func failed() {
        XCTFail(description, file: file, line: line)
    }
}

public class ExpectThunk<State: Equatable> {
    private var dispatch: DispatchFunction {
        return { action in
            self.dispatched.append(action)
            guard self.dispatchAssertions.isEmpty == false else {
                return
            }
            self.dispatchAssertions.remove(at: 0).associated(action)
        }
    }
    private var dispatchAssertions = [ExpectThunkAssertion<DispatchFunction>]()
    public var dispatched = [Action]()
    private var getState: () -> State? {
        return {
            return self.getStateAssertions.isEmpty ? nil : self.getStateAssertions.removeFirst().associated
        }
    }
    private var getStateAssertions = [ExpectThunkAssertion<State>]()
    private let thunk: Thunk<State>

    public init(_ thunk: Thunk<State>) {
        self.thunk = thunk
    }
}

extension ExpectThunk {
    public func dispatches<A: Action & Equatable>(_ expected: A,
                                                  file: StaticString = #file,
                                                  line: UInt = #line) -> Self {
        dispatchAssertions.append(
            ExpectThunkAssertion(
                description: "Unfulfilled dispatches: \(expected)",
                file: file,
                line: line
            ) { received in
                XCTAssert(
                    received as? A == expected,
                    "Dispatched action does not equal expected: \(received) \(expected)",
                    file: file,
                    line: line
                )
            }
        )
        return self
    }

    public func dispatches(file: StaticString = #file,
                           line: UInt = #line,
                           dispatch assertion: @escaping DispatchFunction) -> Self {
        dispatchAssertions.append(
            ExpectThunkAssertion(
                description: "Unfulfilled dispatches: dispatch assertion",
                file: file,
                line: line,
                associated: assertion
            )
        )
        return self
    }
}

extension ExpectThunk {
    public func getsState(_ state: State,
                          file: StaticString = #file,
                          line: UInt = #line) -> Self {
        getStateAssertions.append(
            ExpectThunkAssertion(
                description: "Unfulfilled getsState: \(state)",
                file: file,
                line: line,
                associated: state
            )
        )
        return self
    }
}

extension ExpectThunk {
    @discardableResult
    public func run(file: StaticString = #file, line: UInt = #line) -> Self {
        createThunkMiddleware()(dispatch, getState)({ _ in })(thunk)
        failLeftovers()
        return self
    }

    @discardableResult
    public func wait(timeout seconds: TimeInterval = 1,
                     file: StaticString = #file,
                     line: UInt = #line,
                     description: String = "\(ExpectThunk.self)") -> Self {
        let expectation = XCTestExpectation(description: description)
        defer {
            if XCTWaiter().wait(for: [expectation], timeout: seconds) != .completed {
                XCTFail("Asynchronous wait failed: unfulfilled dispatches", file: file, line: line)
            }
            failLeftovers()
        }
        let dispatch: DispatchFunction = {
            self.dispatch($0)
            if self.dispatchAssertions.isEmpty == true {
                expectation.fulfill()
            }
        }
        createThunkMiddleware()(dispatch, getState)({ _ in })(thunk)
        return self
    }

    private func failLeftovers() {
        dispatchAssertions.forEach { $0.failed() }
        getStateAssertions.forEach { $0.failed() }
    }
}
