//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 16/12/23.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableLocalFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableLocalFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(_ local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, imageURL: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        
        let codableFeedImages = feed.map(CodableLocalFeedImage.init)
        
        let cache = Cache(feed: codableFeedImages, timestamp: timestamp)
        
        do {
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

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
        
        XCTAssertNil(firstInsertionError)
        
        let (_, latestLocal) = uniqueImages()
        let latestTimestamp = Date()
        
        let latestInsertionError = insert((latestLocal, latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError)
        
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
    
    // MARK: Helpers
    private func makeSUT(with storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
             expect(sut, toRetrieve: expectedResult, file: file, line: line)
             expect(sut, toRetrieve: expectedResult, file: file, line: line)
         }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrievedCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
