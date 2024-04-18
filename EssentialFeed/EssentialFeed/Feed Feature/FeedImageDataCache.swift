//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 12/04/24.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
