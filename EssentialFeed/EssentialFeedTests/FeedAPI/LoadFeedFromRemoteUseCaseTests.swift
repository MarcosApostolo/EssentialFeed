//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 05/12/23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 400, 300, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData), when: {
                let json = makeItemsJson(with: [])
                
                client.complete(withStatusCode: 400, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData), when: {
            let invalidJSON = Data("Invalid json".utf8)
            
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = makeItemsJson(with: [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItems(id: UUID(), imageURL: URL(string: "https://some-url")!)
        
        
        let item2 = makeItems(id: UUID(), description: "some descrption", location: "some location", imageURL: URL(string: "https://another-url")!)
        
        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let json = makeItemsJson(with: [item1.json, item2.json])
            
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://some-url")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeItemsJson(with jsonItems: [[String: Any]]) -> Data {
        let json = ["items": jsonItems]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItems(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        
        let feedItem = FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.url.absoluteString
        ].compactMapValues({ $0 })
        
        return (feedItem, json)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load to complete")
                
        sut.load(completion: { receivedResult in
            switch(expectedResult, receivedResult) {
            case let (.success(expecedItems), .success(receivedItems)):
                XCTAssertEqual(expecedItems, receivedItems, file: file, line: line)
            case let (.failure(expectedError as RemoteFeedLoader.Error), .failure(receivedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
