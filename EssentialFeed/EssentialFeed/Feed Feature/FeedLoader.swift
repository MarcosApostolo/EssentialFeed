//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 05/12/23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
