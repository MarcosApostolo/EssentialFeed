//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 05/03/24.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                guard let image = try? ManagedFeedImage.first(with: url, in: context) else { return }
                
                image.data = data
                try? context.save()
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                return try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }

}
