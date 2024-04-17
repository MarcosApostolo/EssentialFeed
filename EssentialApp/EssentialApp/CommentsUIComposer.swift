//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Marcos Amaral on 17/04/24.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>

public final class CommentsUIComposer {
    private init () {}
    
    public static func commentsComposeWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        let feedPresenterAdapter = FeedPresentationAdapter(loader: commentsLoader)
        
        let feedController = ListViewController.makeFeedViewController(title: ImageCommentsPresenter.title)
        
        feedController.onRefresh = feedPresenterAdapter.loadResource
        
        feedPresenterAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher()}),
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
