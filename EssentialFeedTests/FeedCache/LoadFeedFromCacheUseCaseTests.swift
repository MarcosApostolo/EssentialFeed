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
    
    func test_shouldDeliverCachedImagesWhenCacheIsLessThanSevenDaysOld() {

        let fixedCurrentDate = Date()
        
        let lessThanSevenDays = fixedCurrentDate.add(days: -7).add(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (images, local) = uniqueImages()
                
        expect(sut, toCompleteWith: .success(images), when: {
            store.completeRetrieval(with: local, timestamp: lessThanSevenDays)
        })
    }
    
    func test_shouldDeliverEmptyImagesWhenCacheIsSevenDaysOld() {
        let fixedCurrentDate = Date()
        
        let sevenDaysOld = fixedCurrentDate.add(days: -7)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: local, timestamp: sevenDaysOld)
        })
    }
    
    func test_shouldDeliverEmptyImagesWhenCacheIsMoreThanSevenDaysOld() {
        let fixedCurrentDate = Date()
        
        let tenDaysOld = fixedCurrentDate.add(days: -10)
        
        let (sut, store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        
        let (_, local) = uniqueImages()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: local, timestamp: tenDaysOld)
        })
    }
    
    func test_shouldNotDeleteWhenRetrievalError() {
        let (sut, store) = makeSUT()
        
        let error = anyError()
        
        sut.load { _ in }
        
        store.completeRetrieval(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_shouldNotDeleteCacheWhenEmptyCache() {
        let (sut, store) = makeSUT()
                
        sut.load { _ in }
        
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
        
        sut.load { _ in }

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
        
        sut.load { _ in }

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
        
        sut.load { _ in }

        store.completeRetrieval(with: local, timestamp: sevenDaysOld)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_shouldNotDeliverResultAfterSUTDeallocation() {
        let store = FeedStoreSpy()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        let error = anyError()
        
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
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        
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
    
    fileprivate func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func uniqueImages() -> (model: [FeedImage], local: [LocalFeedImage]) {
        let images = [uniqueImage(), uniqueImage()]
        
        let localImages = images.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
        
        return (images, localImages)
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
