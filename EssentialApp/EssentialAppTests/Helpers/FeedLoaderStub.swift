//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Marcos Amaral on 12/04/24.
//

import Foundation
import EssentialFeed

class FeedLoaderStub {
    private let result: Swift.Result<[FeedImage], Error>

    init(result: Swift.Result<[FeedImage], Error>) {
        self.result = result
    }

    func load(completion: @escaping (Swift.Result<[FeedImage], Error>) -> Void) {
        completion(result)
    }
}
