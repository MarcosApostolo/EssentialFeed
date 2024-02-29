//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 26/12/23.
//

import UIKit
import EssentialFeed

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, FeedLoadingView, FeedErrorView {
    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet private(set) public var errorView: ErrorView?
    
    public override func viewDidLoad() {
        refresh()
    }
    
    var delegate: FeedViewControllerDelegate?
    
    public override func viewIsAppearing(_ animated: Bool) {
        refreshControl?.beginRefreshing()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isLoading: viewModel.isLoading)
    }
    
    func display(_ viewModel: FeedErrorViewModel) {
        if let errorMessage = viewModel.message {
            errorView?.show(message: errorMessage)
        } else {
            errorView?.hideMessage()
        }
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        
        let cell = cellController.view(in: tableView)
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(forRowAt: indexPath)
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = cellController(forRowAt: indexPath)
            
            cellController.preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }
}
