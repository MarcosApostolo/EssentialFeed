//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 03/01/24.
//

import Foundation
import EssentialFeed

public final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: Observer<[FeedImage]>?
    var onLoadStateChange: Observer<Bool>?

    func loadFeed() {
        onLoadStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadStateChange?(false)
        }
    }
}
