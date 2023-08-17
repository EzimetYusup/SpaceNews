//
//  ViewController.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 1/31/23.
//

import Combine
import CombineCocoa
import ReSwift
import SDWebImage
import TinyConstraints
import UIKit

/// News List View Controller - screen that shows list of news in UITableView
/// shows loader while fetching articles, can  scroll infinitely via fetching new articles each time while approaching end of scroll
/// shows error screen in case of various errors
/// supports retry if fetching articles fails
class NewsListViewController: UIViewController, Loadable, Failable {

    /// state container which will hold loader and failed error state view
    var stateContainerView: UIView = UIView()

    /// tableview displays all the news article as list
    let tableView: UITableView = UITableView()

    /// loading indicator
    var loader: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)

    /// list news articles being displayed
    var articles: [Article] = []

    var cancellables = Set<AnyCancellable>()

    /// custom push/pop transition animator
    var animator: CustomAnimator!

    /// UITableview Cell Identifier for news cell
    let newsCellIdentifier = "newsCell"

    // MARK: LifeCycle methods of ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // set title of navigation bar
        title = "Space News"
        view.backgroundColor = .systemBackground
        navigationController?.delegate = self
        setupTableView()
        addStateContainer()
        // start fetching news article
        mainStore.dispatch(fetchArticle)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }

    /// Setup  UITableView for news articles
    func setupTableView() {
        // auto layout for UITableview
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            // set constraints for UITable view
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(NewsCell.self, forCellReuseIdentifier: newsCellIdentifier)
        tableView.accessibilityIdentifier = "tableView"
        tableView.separatorStyle = .none
        tableView.dataSource = datasource

        // initiate empty snapshot for tableview
        var snapshot = NSDiffableDataSourceSnapshot<Int, Article>()
        snapshot.appendSections([0])
        snapshot.appendItems(articles, toSection: 0)
        datasource.apply(snapshot)

        tableView.estimatedRowHeight = 112
        // table view cell tap event
        tableView.didSelectRowPublisher
            .map {
                // deselect the selected row
                self.tableView.deselectRow(at: $0, animated: true)
                guard let cell: NewsCell = self.tableView.cellForRow(at: $0) as? NewsCell else {
                    return self.articles[$0.row]
                }
                self.animator = CustomAnimator(isPresenting: true, newsCell: cell)
                return self.articles[$0.row]
            }
            .map(MainStateAction.didTapArticle)
            .sink { mainStore.dispatch($0) }
            .store(in: &cancellables)

        // infinite load next page as tableview reaches the bottom
        tableView.willDisplayCellPublisher
            .filter { $1.row == mainStore.state.articles.count - 1 }
            .map { _ in fetchArticle }
            .sink { mainStore.dispatch($0) }
            .store(in: &cancellables)
    }

    // MARK: tableview data source
    lazy var datasource: UITableViewDiffableDataSource<Int, Article> = {
      let datasource = UITableViewDiffableDataSource<Int, Article>(tableView: tableView, cellProvider: { (tableView, indexPath, article) -> UITableViewCell? in
          guard let cell = tableView.dequeueReusableCell(withIdentifier: self.newsCellIdentifier, for: indexPath) as? NewsCell else { fatalError("check news cell type")}
          cell.titleLabel.text = article.title
          if let url = URL(string: article.imageUrl) {
              let placeHolder = UIImage(systemName: "photo")
              let scale = UIScreen.main.scale // Will be 2.0 on 6/7/8 and 3.0 on 6+/7+/8+ or later
              let thumbnailSize = CGSize(width: 145 * scale, height: 100 * scale) // Thumbnail will bounds to (145, 100) points
              cell.thumbNail.sd_setImage(with: url, placeholderImage: placeHolder, context: [.imageThumbnailPixelSize: thumbnailSize]) // this makes huge difference in memory usage especially if the image is large
          }
          cell.accessibilityIdentifier = "news_cell_\(indexPath.row)"
          return cell
      })
      return datasource
    }()
}

// MARK: ReSwift StoreSubscriber
extension NewsListViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MainState

    /// Observes news state, and update the view's content based on state change
    /// - Parameter state: MainState
    func newState(state: MainState) {
        // push to news details screen, if newsDetailStatus has changed
        if case .show =  state.newsDetailStatus {
            let detailsViewController = NewsDetailViewController(nibName: nil, bundle: .main)
            self.navigationController?.pushViewController(detailsViewController, animated: true)
            return
        }
        // sync loader view based on loader state
        updateLoaderState(state.loadingState)

        // get the difference of articles, and append it to the snapshot
        let inserted = state.articles - self.articles
        if inserted.isEmpty {
            return
        }
        self.articles = state.articles
        var snapshot = datasource.snapshot()
        let newArticles: [Article] = inserted
        snapshot.appendItems(newArticles, toSection: 0)
        datasource.apply(snapshot, animatingDifferences: false)
    }

    /// Updates loader view based on loading state
    /// - Parameter state: LoadingState
    func updateLoaderState(_ state: LoadingState) {
        // make sure we are updating UI in main thread
        Task {
            switch state {
            case .loading:
                // hide failed view if necessary, show loader only
                hideFailedView()
                showLoader()
            case .idle:
                // hide loader and failed view
                hideLoader()
                hideFailedView()
            case .failed(let errorMessage):
                // hide loader, and show error state view
                hideLoader()
                showFailedView(errorMessage ?? "Oh Snap, we hit a snag, try again later")
            }
        }
    }

}

// MARK: Retriable implementation 
extension NewsListViewController: Retriable {

    /// User did press retry button, will fetch news article now
    func didPressRetry() {
        mainStore.dispatch(fetchArticle)
    }
}

// MARK: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate implementation for custom push/pop animation
extension NewsListViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // need to set whether we are pushing or popping to navigation stack
        animator.isPresenting = !(operation == .pop)
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }

}
