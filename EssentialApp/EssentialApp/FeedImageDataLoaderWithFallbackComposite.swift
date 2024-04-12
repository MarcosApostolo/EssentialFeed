//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Marcos Amaral on 11/04/24.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primaryLoader: FeedImageDataLoader
    let fallbackLoader: FeedImageDataLoader
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }

    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryLoader = primary
        self.fallbackLoader = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        let task = TaskWrapper()
        
        task.wrapped = primaryLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallbackLoader.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}
