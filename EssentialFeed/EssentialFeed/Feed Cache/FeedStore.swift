//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 13/12/23.
//

import Foundation

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CacheFeed?
}
