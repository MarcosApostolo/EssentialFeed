//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 02/03/24.
//

import Foundation
import EssentialFeed

public func anyData() -> Data {
    return Data("any data".utf8)
}

public func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

public func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

public func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

public func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let images = [uniqueImage(), uniqueImage()]
    
    let localImages = images.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
    }
    
    return (images, localImages)
}

extension Date {
    private func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return add(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}

func makeItemsJson(with jsonItems: [[String: Any]]) -> Data {
    let json = ["items": jsonItems]
    
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
