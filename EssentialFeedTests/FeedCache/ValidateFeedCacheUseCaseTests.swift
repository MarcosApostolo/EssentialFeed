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
}
