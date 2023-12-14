//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 13/12/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias RetrieveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (RetrieveResult) -> Void) {
        self.store.retrieve { error in
            completion(error)
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocalFeedItem(), timestamp: self.currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocalFeedItem() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
    }
}
