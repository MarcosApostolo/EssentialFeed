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
        
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        
        let codableFeedImages = feed.map(CodableLocalFeedImage.init)
        
        let cache = Cache(feed: codableFeedImages, timestamp: timestamp)
        
        let encoded = try! encoder.encode(cache)
        
        try! encoded.write(to: storeURL)
        
        completion(nil)
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
        
        let exp = expectation(description: "Wait to finish")
                
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, but got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldNotHaveSideEffectsAndDeliverEmptyTwiceWhenEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait to finish")
           
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected empty results, but got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverCacheWhenRetrievingAfterInsert() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait to finish")
        
        let (_, local) = uniqueImages()
        
        let timestamp = Date()
           
        sut.insert(local, timestamp: timestamp) { insertioError in
            XCTAssertNil(insertioError)
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(feed: retrievedFeed, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, local)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("Expected found result, but got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverSameCacheWhenRetrievingTwiceAfterInsert() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait to finish")
        
        let (_, local) = uniqueImages()
        
        let timestamp = Date()
           
        sut.insert(local, timestamp: timestamp) { insertioError in
            XCTAssertNil(insertioError)
            
            sut.retrieve { retrieveResult in
                sut.retrieve { secondResult in
                    switch (retrieveResult, secondResult) {
                    case let ((.found(feed: retrievedFirstFeed, retrievedFirstTimestamp), .found(feed: retrievedSecondFeed, timestamp: retrievedSecondTimestamp))):
                        XCTAssertEqual(retrievedFirstFeed, local)
                        XCTAssertEqual(retrievedSecondFeed, local)
                        
                        XCTAssertEqual(retrievedFirstTimestamp, timestamp)
                        XCTAssertEqual(retrievedSecondTimestamp, timestamp)
                    default:
                        XCTFail("Expected retrieving twice would get the same results, but got different results instead")
                    }
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
