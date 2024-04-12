//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 12/04/24.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(feed: [FeedImage], completion: @escaping (Result) -> Void)
}
