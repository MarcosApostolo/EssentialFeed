//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 26/12/23.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private(set) var feedImageDataLoaderTask = [IndexPath: FeedImageDataLoaderTask]()
    public var feedRefreshViewController: FeedRefreshViewController?
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        
        self.imageLoader = imageLoader
        self.feedRefreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
    }
    
    public override func viewDidLoad() {
        refreshControl = feedRefreshViewController?.view
        feedRefreshViewController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        tableView.prefetchDataSource = self
        
        feedRefreshViewController?.refresh()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        refreshControl?.beginRefreshing()
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        feedImageDataLoaderTask[indexPath]?.cancel()
        feedImageDataLoaderTask[indexPath] = nil
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: model, imageLoader: imageLoader!)
        
        cellControllers[indexPath] = cellController
        
        let cell = cellController.view()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
        cellControllers[indexPath] = nil
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            feedImageDataLoaderTask[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
}
