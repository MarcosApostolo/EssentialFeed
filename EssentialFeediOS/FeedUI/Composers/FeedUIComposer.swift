//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 03/01/24.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init () {}
    
    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedRefreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: feedRefreshViewController)
        
        feedRefreshViewController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
