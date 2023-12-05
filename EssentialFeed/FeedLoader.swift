//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 05/12/23.
//

import Foundation

enum FeedLoaderResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func loadItems(completion: @escaping (FeedLoaderResult) -> Void)
}
