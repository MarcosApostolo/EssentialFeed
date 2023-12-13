//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 05/12/23.
//

import Foundation

public enum FeedLoaderResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}
