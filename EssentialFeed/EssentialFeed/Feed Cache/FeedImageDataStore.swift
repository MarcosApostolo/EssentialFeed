//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 04/03/24.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
