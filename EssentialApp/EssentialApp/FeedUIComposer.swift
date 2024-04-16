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

private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>

public final class FeedUIComposer {
    private init () {}
    
    public static func feedComposeWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        let feedPresenterAdapter = FeedPresentationAdapter(loader: feedLoader)
        
        let feedController = ListViewController.makeFeedViewController(title: FeedPresenter.title)
        
        feedController.onRefresh = feedPresenterAdapter.loadResource
        
        feedPresenterAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(
                feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
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





