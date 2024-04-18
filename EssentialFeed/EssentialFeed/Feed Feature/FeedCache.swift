//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 12/04/24.
//

import Foundation

public protocol FeedCache {
    func save(feed: [FeedImage]) throws
}
