//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 29/02/24.
//

import Foundation

public final class FeedPresenter {
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        return FeedViewModel(feed: feed)
    }
}
