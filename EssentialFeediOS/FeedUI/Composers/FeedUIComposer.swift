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
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshViewController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: feedRefreshViewController)
        
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                let viewModel = FeedImageViewModel(imageLoader: loader, feedImage: model, imageTransformer: UIImage.init)
                
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}
