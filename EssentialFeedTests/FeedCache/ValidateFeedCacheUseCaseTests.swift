//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 14/12/23.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_shouldNotMessageStoreWhenCreatingCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_shouldDeleteWhenRetrievalError() {
        let (sut, store) = makeSUT()
        
        let error = anyError()
        
        sut.validateCache()
        
        store.completeRetrieval(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_shouldNotDeleteCacheWhenEmptyCache() {
        let (sut, store) = makeSUT()
                
        sut.validateCache()
        
        store.completeWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldNotDeleteCacheWhenCacheIsLessThanSevenDaysOld() {
        let fixedCurrentDate = Date()
        
        let lessThanSevenDays = fixedCurrentDate.add(days: -7).add(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        sut.validateCache()

        store.completeRetrieval(with: local, timestamp: lessThanSevenDays)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    fileprivate func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
        let images = [uniqueImage(), uniqueImage()]
        
        let localImages = images.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
        
        return (images, localImages)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}

private extension Date {
    func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func add(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
