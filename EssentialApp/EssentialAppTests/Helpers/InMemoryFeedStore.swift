//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Marcos Amaral on 13/04/24.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private(set) var feedCache: CacheFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    private init(feedCache: CacheFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        feedCache = CacheFeed(feed: feed, timestamp: timestamp)
    }

    func retrieve() throws -> CacheFeed? {
        feedCache
    }
    
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date.distantPast))
    }

    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date()))
    }
}
