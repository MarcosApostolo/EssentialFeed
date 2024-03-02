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
        
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(expectedError), when: {
            store.completeRetrieval(with: expectedError)
        })
    }
    
    func test_shouldNotDeliverImagesWhenEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeWithEmptyCache()
        })
    }
    
    func test_shouldDeliverCachedImagesWhenCacheIsLessThanNonExpiredCache() {

        let fixedCurrentDate = Date()
        
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().add(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (images, local) = uniqueImages()
                
        expect(sut, toCompleteWith: .success(images), when: {
            store.completeRetrieval(with: local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_shouldDeliverEmptyImagesWhenCacheIsEqualToNonExpiredCacheTimestamp() {
        let fixedCurrentDate = Date()
        
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_shouldDeliverEmptyImagesWhenCacheIsMoreThanExpiredCacheTimestamp() {
        let fixedCurrentDate = Date()
        
        let moreThanExpiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().add(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: local, timestamp: moreThanExpiredCacheTimestamp)
        })
    }
    
    func test_shouldNotHaveSideEffectsWhenRetrievalError() {
        let (sut, store) = makeSUT()
        
        let error = anyNSError()
        
        sut.load { _ in }
        
        store.completeRetrieval(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldNotHaveSideEffectsWhenEmptyCache() {
        let (sut, store) = makeSUT()
                
        sut.load { _ in }
        
        store.completeWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldHaveNoSideEffectsWhenCacheIsLessThanExpiredCacheTimestamp() {
        let fixedCurrentDate = Date()
        
        let expiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().add(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        sut.load { _ in }

        store.completeRetrieval(with: local, timestamp: expiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldNotHaveSideEffectsWhenCacheIsEqualToExpiredCacheTimestamp() {
        let fixedCurrentDate = Date()
        
        let expiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        sut.load { _ in }

        store.completeRetrieval(with: local, timestamp: expiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldNotHaveSideEffectsWhenCacheIsMoreThanExpiredCacheTimestamp() {
        let fixedCurrentDate = Date()
        
        let expiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().add(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        sut.load { _ in }

        store.completeRetrieval(with: local, timestamp: expiredCacheTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldNotDeliverResultAfterSUTDeallocation() {
        let store = FeedStoreSpy()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        let error = anyNSError()
        
        var receivedResult = [LocalFeedLoader.LoadResult]()
        
        sut?.load { result in
            receivedResult.append(result)
        }
        
        sut = nil
        
        store.completeRetrieval(with: error)
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    // MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait to fail")
                
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead.")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

