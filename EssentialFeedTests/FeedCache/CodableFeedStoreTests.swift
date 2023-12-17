import XCTest
@testable import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    override class func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override class func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_shouldDeliverEmptyWhenEmptyCache() {
        let sut = makeSUT()
                
        expect(sut, toRetrieve: .empty)
    }
    
    func test_shouldNotHaveSideEffectsAndDeliverEmptyTwiceWhenEmptyCache() {
        let sut = makeSUT()
                
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_shouldDeliverCacheWhenCacheIsNotEmpty() {
        let sut = makeSUT()
                
        let (_, local) = uniqueImages()
        
        let timestamp = Date()
        
        let insertionError = insert((local, timestamp), to: sut)
        
        XCTAssertNil(insertionError)
        
        expect(sut, toRetrieve: .found(feed: local, timestamp: timestamp))
    }
    
    func test_shouldDeliverSameCacheWhenRetrievingTwiceAfterInsert() {
        let sut = makeSUT()
                
        let (_, local) = uniqueImages()
        
        let timestamp = Date()
        
        let insertionError = insert((local, timestamp), to: sut)
        
        XCTAssertNil(insertionError)
        
        expect(sut, toRetrieve: .found(feed: local, timestamp: timestamp))
    }
    
    func test_shouldDeliverErrorOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        
        let sut = makeSUT(with: storeURL)
        
        try! "invalid json".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func test_shouldDeliverSameErrorTwiceOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        
        let sut = makeSUT(with: storeURL)
        
        try! "invalid json".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func test_shouldOverridePreviousDataWhenInsertingWithNewData() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImages().local, Date()), to: sut)
        
        XCTAssertNil(firstInsertionError, "Expected no insertion error")
        
        let (_, latestLocal) = uniqueImages()
        let latestTimestamp = Date()
        
        let latestInsertionError = insert((latestLocal, latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected no insertion error")
        
        expect(sut, toRetrieve: .found(feed: latestLocal, timestamp: latestTimestamp))
    }
    
    func test_shouldDeliverErrorWhenInsertionFails() {
        let invalidStoreURL = URL(string: "invalid://any.url")
        
        let sut = makeSUT(with: invalidStoreURL)
        
        let (_, feed) = uniqueImages()
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError)
    }
    
    func test_shouldDeliverEmptyCacheWhenDeletingEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected no deletion error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_shouldDeleteCacheWhenCacheIsNonEmpty() {
        let sut = makeSUT()
        
        let (_, feed) = uniqueImages()
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNil(insertionError, "Expected no insertion error")
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected no deletion error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_shouldDeliverErrorWhenDeletionFails() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(with: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffectsShouldRunSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImages().local, timestamp: Date(), completion: { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed(completion: { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImages().local, timestamp: Date(), completion: { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        })
        
        wait(for: completedOperationsInOrder, timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expectation should have finished in order")
    }
    
    // MARK: Helpers
    private func makeSUT(with storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
             expect(sut, toRetrieve: expectedResult, file: file, line: line)
             expect(sut, toRetrieve: expectedResult, file: file, line: line)
         }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrievedCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(feed: retrievedFeed, timestamp: retrievedTimestamp), .found(feed: expectedFeed, timestamp: expectedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
