//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 26/12/23.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        refreshControl?.beginRefreshing()
    }

    @objc private func load() {
        refreshControl?.beginRefreshing()
        
        loader?.load { [weak self] result in
            self?.refreshControl?.endRefreshing()
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
        }
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let cell = FeedImageCell()
        
        cell.locationContainer.isHidden = (model.location == nil)
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        
        return cell
    }
}
