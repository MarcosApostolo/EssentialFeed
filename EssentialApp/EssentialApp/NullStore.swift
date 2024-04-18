//
//  NullStore.swift
//  EssentialApp
//
//  Created by Marcos Amaral on 18/04/24.
//

import Foundation
import EssentialFeed

class NullStore: FeedImageDataStore & FeedStore {
    func deleteCachedFeed() throws {}

    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}

    func retrieve() throws -> CacheFeed? { .none }

    func insert(_ data: Data, for url: URL) throws {}

    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}

