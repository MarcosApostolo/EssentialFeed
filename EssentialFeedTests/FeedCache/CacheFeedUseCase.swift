//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 12/12/23.
//

import XCTest

import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items: items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {        
        receivedMessages.append(.deleteCacheFeed)
        
        self.deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.insert(items, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfuly(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
}

final class CacheFeedUseCase: XCTestCase {

    func test_shouldNotMessageStoreWhenCreatingCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_shouldRequestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_shouldNotRequestInsertionWhenDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        let deletionError = anyError()
        
        sut.save(items: items) { _ in }
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_shouldRequestNewCacheInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let items = [uniqueItems(), uniqueItems()]
                
        sut.save(items: items) { _ in }
        
        store.completeSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
    }
    
    func test_shouldDeliverErrorWhenDeletionFailsWithError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        let exp = expectation(description: "Wait to fail")
        
        let deletionError = anyError()
        var receivedError: Error?
        sut.save(items: items) { error in
            receivedError = error
            
            exp.fulfill()
        }
                
        store.completeDeletion(with: deletionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_shouldDeliverErrorWhenInsertionFailsWithError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        let exp = expectation(description: "Wait to fail")
        
        let insertionError = anyError()
        var receivedError: Error?
        sut.save(items: items) { error in
            receivedError = error
            
            exp.fulfill()
        }
                
        store.completeSuccessfully()
        store.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    func test_shouldDeliverSuccessMessageWhenInsertionSucceeds() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        let exp = expectation(description: "Wait to fail")
        
        var receivedError: Error?
        sut.save(items: items) { error in
            receivedError = error
            
            exp.fulfill()
        }
                
        store.completeSuccessfully()
        store.completeInsertionSuccessfuly()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(receivedError)
    }
    
    // MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    func uniqueItems() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    fileprivate func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
