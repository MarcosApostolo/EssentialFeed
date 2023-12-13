//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 12/12/23.
//

import XCTest

import EssentialFeed

final class CacheFeedUseCase: XCTestCase {

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
                
        let deletionError = anyError()
        
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
        
        let deletionError = anyError()
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_shouldDeliverErrorWhenInsertionFailsWithError() {
        let (sut, store) = makeSUT()
        
        let insertionError = anyError()
        
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
        sut.save(feed: images) { error in
            receivedError = error
            
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
        
        store.completeDeletion(with: anyError())
        
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
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let (items, _) = uniqueImages()
        
        let exp = expectation(description: "Wait to fail")
        
        var receivedError: Error?
        sut.save(feed: items) { error in
            receivedError = error
            
            exp.fulfill()
        }
                
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    fileprivate func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
        let images = [uniqueImage(), uniqueImage()]
        
        let localImages = images.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
        
        return (images, localImages)
    }
    
    
    private class FeedStoreSpy: FeedStore {
        typealias DeletionCompletion = (LocalFeedLoader.SaveResult) -> Void
        typealias InsertionCompletion = (LocalFeedLoader.SaveResult) -> Void
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([LocalFeedImage], Date)
        }
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            receivedMessages.append(.deleteCacheFeed)
            
            self.deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletion(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            receivedMessages.append(.insert(feed, timestamp))
            insertionCompletions.append(completion)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfuly(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
}
