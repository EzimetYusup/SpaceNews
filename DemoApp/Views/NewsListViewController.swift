//
//  ViewController.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 1/31/23.
//

import Combine
import CombineCocoa
import DifferenceKit
import ReSwift
import SDWebImage
import TinyConstraints
import UIKit

class NewsListViewController: UIViewController {

    let tableView: UITableView = UITableView()

    var articles: [Article] = []

    var cancellables = Set<AnyCancellable>()

    var animator: CustomAnimator!

    // MARK: tableview data source
    lazy var datasource: UITableViewDiffableDataSource<Int, Article> = {
      let datasource = UITableViewDiffableDataSource<Int, Article>(tableView: tableView, cellProvider: { (tableView, indexPath, article) -> UITableViewCell? in
          guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewsCell else { fatalError("check news cell type")}
          cell.titleLabel.text = article.title
          if let url = URL(string: article.imageUrl) {
              let placeHolder = UIImage(systemName: "photo")
              cell.thumbNail.sd_setImage(with: url, placeholderImage: placeHolder)
          }
          cell.accessibilityIdentifier = "news_cell_\(indexPath.row)"
          return cell
      })
      return datasource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Space News"
        view.backgroundColor = .systemBackground
        navigationController?.delegate = self
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.edgesToSuperview()
        tableView.register(NewsCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.accessibilityIdentifier = "tableView"
        tableView.separatorStyle = .none
        tableView.dataSource = datasource

        // initiate empty snapshot for tableview
        var snapshot = NSDiffableDataSourceSnapshot<Int, Article>()
        snapshot.appendSections([0])
        snapshot.appendItems(articles, toSection: 0)
        datasource.apply(snapshot)

        // table view cell tap event
        tableView.didSelectRowPublisher
            .map {
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

        // infinite load next page as tableview reach the bottom
        tableView.willDisplayCellPublisher
            .filter { $1.row == mainStore.state.articles.count - 1 }
            .map { _ in fetchArticle }
            .sink { mainStore.dispatch($0) }
            .store(in: &cancellables)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }

}

// MARK: StoreSubscriber
extension NewsListViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MainState

    func newState(state: MainState) {
        // push to news details screen, if state has changed
        if case .show =  state.newsDetailStatus {
            self.navigationController?.pushViewController(NewsDetailViewController(), animated: true)
            return
        }

        // get the difference of articles, and append it to the snapshot
        let changeset = StagedChangeset(source: self.articles, target: state.articles)
        if changeset.isEmpty {
            return
        }

        self.articles = state.articles
        var snapshot = datasource.snapshot()
        let inserted = changeset[0].elementInserted
        let newArticles: [Article] = Array(state.articles[inserted.first!.element...inserted.last!.element])
        snapshot.appendItems(newArticles, toSection: 0)
        datasource.apply(snapshot)
    }

}

extension NewsListViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        animator.isPresenting = !(operation == .pop)
        return animator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }

}
