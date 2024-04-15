//
//  RemoteFeedImageDateLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 01/03/24.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let httpCodes = [199, 201, 300, 400, 500]
        
        try httpCodes.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() throws {
        let emptyData = Data()
        
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty".utf8)
        
        let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, nonEmptyData)
    }
}
