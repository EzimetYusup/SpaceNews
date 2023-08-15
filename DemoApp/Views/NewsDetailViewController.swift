//
//  NewsDetailViewController.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 2/8/23.
//

import Foundation
import ReSwift
import UIKit

class NewsDetailViewController: UIViewController {

    var article: Article!

    // MARK: Views
    let scrollView =  UIScrollView()

    let scrollViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    let articleTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle, compatibleWith: .none)
        label.numberOfLines = 0
        label.accessibilityIdentifier = TestingHelper.articleTitleLabelIdentifier
        return label
    }()

    let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let articleSummary: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, compatibleWith: .none)
        label.numberOfLines = 0
        label.accessibilityIdentifier = TestingHelper.articleSummaryLabelIdentifier
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
    }

    private func setupSubViews() {
        view.backgroundColor = .containerBackground
        view.addSubview(scrollView)
        setUpScrollViewAndContent()
    }

    private func setUpScrollViewAndContent() {
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            // set constraints for scroll view
            scrollView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // set constraints for container inside scrollview
            scrollViewContainer.widthAnchor.constraint(equalTo: margins.widthAnchor),
            scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)

        ])

        scrollViewContainer.addArrangedSubview(articleTitleLabel)
        scrollViewContainer.addArrangedSubview(articleImageView)
        scrollViewContainer.addArrangedSubview(articleSummary)

        articleImageView.height(view.frame.width*0.65)
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
}

extension NewsDetailViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MainState

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
