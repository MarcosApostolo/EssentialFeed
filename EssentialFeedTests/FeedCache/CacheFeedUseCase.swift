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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount = deleteCachedFeedCallCount + 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
    }
}

final class CacheFeedUseCase: XCTestCase {

    func test_shouldNotDeleteWhenCreatingCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_shouldRequestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_shouldNotRequestInsertionWhenDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItems(), uniqueItems()]
        
        let deletionError = anyError()
        
        sut.save(items: items)
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // MARK: Helpers
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        
        let sut = LocalFeedLoader(store: store)
        
        checkForMemoryLeaks(sut)
        checkForMemoryLeaks(store)
        
        return (sut, store)
    }
    
    func uniqueItems() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    fileprivate func anyError() -> Error {
        return NSError(domain: "any error", code: 1)
    }
}
