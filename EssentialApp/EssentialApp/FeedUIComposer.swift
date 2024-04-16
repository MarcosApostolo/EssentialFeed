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
        
        let listController = ListViewController.makeWith(
            delegate: feedPresenterAdapter,
            title: FeedPresenter.title)
        
        feedPresenterAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: listController,
                imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(
                listController),
            errorView: WeakRefVirtualProxy(listController),
            mapper: FeedPresenter.map
        )
                
        return listController
    }
}

private extension ListViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}





