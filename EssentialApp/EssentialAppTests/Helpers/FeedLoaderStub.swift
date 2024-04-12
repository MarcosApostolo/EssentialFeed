//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Marcos Amaral on 12/04/24.
//

import Foundation
import EssentialFeed

class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
