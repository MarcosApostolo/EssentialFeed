//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 13/12/23.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocalFeedItem(), timestamp: self.currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .success: break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocalFeedItem() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
