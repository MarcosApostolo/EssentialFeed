//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 14/12/23.
//

import Foundation
import EssentialFeed

func anyError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let images = [uniqueImage(), uniqueImage()]
    
    let localImages = images.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
    }
    
    return (images, localImages)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}


extension Date {
    func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func add(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return add(days: -7)
    }
}
