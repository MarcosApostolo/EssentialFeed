//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 27/12/23.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    lazy public var view: UIRefreshControl = {
        view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }()
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc public func refresh() {
        view.beginRefreshing()
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            
            self?.view.endRefreshing()
        }
    }
}
