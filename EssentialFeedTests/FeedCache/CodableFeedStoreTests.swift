//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 16/12/23.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    func test_shouldDeliverEmptyWhenEmptyCache() {
        let sut = CodableFeedStore()
        
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
}
