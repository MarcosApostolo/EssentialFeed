//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 04/03/24.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
