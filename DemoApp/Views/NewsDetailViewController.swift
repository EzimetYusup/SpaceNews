//
//  NewsDetailViewController.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/8/23.
//

import Foundation
import ReSwift
import UIKit

/// NewsDetailViewController - News Details screen
/// shows news article details includes news image, title and description
class NewsDetailViewController: UIViewController {

    // news article being displayed
    var article: Article!

    // MARK: Views
    // mains scrollview container
    let scrollView =  UIScrollView()
    // sub view of scroll view, contains title, image, description of news article
    let scrollViewContent: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    // news article title label
    let articleTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle, compatibleWith: .none)
        label.numberOfLines = 0
        label.accessibilityIdentifier = AccessibilityID.articleTitleLabel
        return label
    }()

    // news article image
    let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    // news article description or summary
    let articleSummary: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, compatibleWith: .none)
        label.numberOfLines = 0
        label.accessibilityIdentifier = AccessibilityID.articleSummaryLabel
        return label
    }()

    // MARK: lifecycle of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .containerBackground
        setupSubViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
        mainStore.dispatch(MainStateAction.willHide(article))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainStore.dispatch(MainStateAction.hideNewsDetail)
    }

    // set up news detail contents
    private func setupSubViews() {
        view.addSubview(scrollView)
        setUpScrollViewAndContent()
    }

    // setup scroll view and it's sub views
    private func setUpScrollViewAndContent() {
        scrollView.addSubview(scrollViewContent)
        scrollViewContent.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            // set constraints for scroll view
            scrollView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // set constraints for container inside scrollview
            scrollViewContent.widthAnchor.constraint(equalTo: margins.widthAnchor),
            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // set height of image view
            articleImageView.heightAnchor.constraint(equalToConstant: view.frame.width*0.65)

        ])

        scrollViewContent.addArrangedSubview(articleTitleLabel)
        scrollViewContent.addArrangedSubview(articleImageView)
        scrollViewContent.addArrangedSubview(articleSummary)
    }
}

// MARK: ReSwift StoreSubscriber Implementation
extension NewsDetailViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MainState

    /// Observes news state, and update the view's content based on state change
    /// - Parameter state: MainState
    func newState(state: MainState) {
        if case .show(let article) = state.newsDetailStatus {
            self.article = article
            articleTitleLabel.text = article.title
            let placeHolder = UIImage(systemName: "photo")
            articleImageView.sd_setImage(with: URL(string: article.imageUrl), placeholderImage: placeHolder)
            articleSummary.text = article.summary
        }
    }
}
