//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 13/12/23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_shouldNotMessageStoreWhenCreatingCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_shouldRequestCacheRetrievalFromStoreWhenLoadIsCalled() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldReceiveErrorWhenRetrievalError() {
        let (sut, store) = makeSUT()
        
        let expectedError = anyError()
        
        var receivedError: Error?
        let exp = expectation(description: "Wait to fail")
        
        sut.load { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeRetrieval(with: expectedError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    // MARK: Helpers
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
