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
        
        feedRefreshViewController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
