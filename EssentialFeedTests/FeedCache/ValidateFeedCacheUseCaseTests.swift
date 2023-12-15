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
    
    func test_shouldDeleteCacheWhenCacheIsSevenDaysOld() {
        let fixedCurrentDate = Date()
        
        let sevenDaysOld = fixedCurrentDate.add(days: -7)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        sut.validateCache()

        store.completeRetrieval(with: local, timestamp: sevenDaysOld)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_shouldDeleteCacheWhenCacheIsMoreThanSevenDaysOld() {
        let fixedCurrentDate = Date()
        
        let sevenDaysOld = fixedCurrentDate.add(days: -10)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        sut.validateCache()

        store.completeRetrieval(with: local, timestamp: sevenDaysOld)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_shouldNotDeleteCacheAfterSUTDeallocation() {
        let store = FeedStoreSpy()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
}
