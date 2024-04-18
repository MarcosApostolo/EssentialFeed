//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 03/01/24.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

public final class FeedUIComposer {
    private init () {}
    
    public static func feedComposeWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        let feedPresenterAdapter = FeedPresentationAdapter(loader: feedLoader)
        
        let feedController = ListViewController.makeFeedViewController(title: FeedPresenter.title)
        
        feedController.onRefresh = feedPresenterAdapter.loadResource
        
        feedPresenterAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader,
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(
                feedController),
            errorView: WeakRefVirtualProxy(feedController)
        )
                
        return feedController
    }
}

private extension ListViewController {
    static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let listController = storyboard.instantiateInitialViewController() as! ListViewController
        listController.title = title
        return listController
    }
}

