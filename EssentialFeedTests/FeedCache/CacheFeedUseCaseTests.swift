//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 12/12/23.
//

import XCTest

import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {

    func test_shouldNotMessageStoreWhenCreatingCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_shouldRequestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let (images, _) = uniqueImages()
        
        sut.save(feed: images) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_shouldNotRequestInsertionWhenDeletionError() {
        let (sut, store) = makeSUT()
                
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_shouldRequestNewCacheInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let (images, localImages) = uniqueImages()
                
        sut.save(feed: images) { _ in }
        
        store.completeDeletion()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(localImages, timestamp)])
    }
    
    func test_shouldDeliverErrorWhenDeletionFailsWithError() {
        let (sut, store) = makeSUT()
        
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_shouldDeliverErrorWhenInsertionFailsWithError() {
        let (sut, store) = makeSUT()
        
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWith: insertionError, when: { 
            store.completeDeletion()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_shouldDeliverSuccessMessageWhenInsertionSucceeds() {
        let (sut, store) = makeSUT()
        
        let (images, _) = uniqueImages()
        
        let exp = expectation(description: "Wait to fail")
        
        var receivedError: Error?
        sut.save(feed: images) { result in
            if case let Result.failure(error) = result {
                receivedError = error
            }
            
            exp.fulfill()
        }
                
        store.completeDeletion()
        store.completeInsertionSuccessfuly()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(receivedError)
    }
    
    func test_shouldNotDeliverDeletionErrorAfterDealloc() {
        let store = FeedStoreSpy()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        
        let (images, _) = uniqueImages()
        
        sut?.save(feed: images, completion: { receivedResults.append($0) })
        
        sut = nil
        
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_shouldNotDeliverInsertionErrorAfterDealloc() {
        let store = FeedStoreSpy()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        
        let (images, _) = uniqueImages()
        
        sut?.save(feed: images, completion: { receivedResults.append($0) })
        
        store.completeDeletion()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let (items, _) = uniqueImages()
        
        let exp = expectation(description: "Wait to fail")
        
        var receivedError: Error?
        sut.save(feed: items) { result in
            if case let Result.failure(error) = result {
                receivedError = error
            }
            
            exp.fulfill()
        }
                
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
}
