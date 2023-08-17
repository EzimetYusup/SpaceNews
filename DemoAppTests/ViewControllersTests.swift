//
//  DemoAppTests.swift
//  DemoAppTests
//
//  Created by Ezimet Ozkhan on 1/31/23.
//

import XCTest
@testable import DemoApp

final class ViewControllersTests: XCTestCase {

    func testNewsListVC() throws {
        let newsListVC = NewsListViewController()
        newsListVC.loadViewIfNeeded()
        XCTAssertEqual(newsListVC.title, "Space News")
        XCTAssertEqual(newsListVC.view.backgroundColor, .systemBackground)
        XCTAssertNotNil(newsListVC.tableView)
        XCTAssertEqual(newsListVC.tableView.separatorStyle, .none)
    }

    func testNewsDetailVC() throws {
        let newsDetailVC = NewsDetailViewController()
        newsDetailVC.loadViewIfNeeded()
        XCTAssertNil(newsDetailVC.title)
        XCTAssertNotNil(newsDetailVC.scrollView)
        XCTAssertNotNil(newsDetailVC.scrollViewContent)
        XCTAssertEqual(newsDetailVC.scrollViewContent.axis, .vertical)
        XCTAssertEqual(newsDetailVC.view.backgroundColor?.cgColor, UIColor.containerBackground.cgColor)
        XCTAssertEqual(newsDetailVC.articleTitleLabel.font, .preferredFont(forTextStyle: .largeTitle, compatibleWith: .none))
        XCTAssertEqual(newsDetailVC.articleTitleLabel.numberOfLines, 0)
        XCTAssertEqual(newsDetailVC.articleTitleLabel.textAlignment, .center)

        XCTAssertEqual(newsDetailVC.articleSummary.font, .preferredFont(forTextStyle: .body, compatibleWith: .none))
        XCTAssertEqual(newsDetailVC.articleSummary.numberOfLines, 0)
        XCTAssertEqual(newsDetailVC.articleSummary.textAlignment, .natural)
    }

}
