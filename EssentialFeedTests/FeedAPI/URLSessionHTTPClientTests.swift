//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 07/12/23.
//

import Foundation
import XCTest

import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_shouldFailWhenWrongURL() {
        let url = makeURL()
        
        let exp = expectation(description: "Some description")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        let sut = makeSUT()
        
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        let receivedError = resultWithError(data: nil, response: nil, error: requestError)! as NSError
        
        XCTAssertEqual(receivedError.domain, requestError.domain)
        XCTAssertEqual(receivedError.code, requestError.code)
    }
    
    func test_shouldFailWhenUnexpectedDataRepresentation() {
        XCTAssertNotNil(resultWithError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultWithError(data: nil, response: anyNonHttpURLResponse(), error: nil))
        XCTAssertNotNil(resultWithError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultWithError(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultWithError(data: nil, response: anyNonHttpURLResponse(), error: anyError()))
        XCTAssertNotNil(resultWithError(data: nil, response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultWithError(data: anyData(), response: anyNonHttpURLResponse(), error: anyError()))
        XCTAssertNotNil(resultWithError(data: anyData(), response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultWithError(data: anyData(), response: anyNonHttpURLResponse(), error: nil))
    }
    
    func test_shouldGetDataAndResponseWhenCorrectRequest() {
        let data = anyData()
        let response = anyHttpUrlResponse()
        
        let receivedValues = resultWithValues(data: data, response: response, error: nil)
        
        XCTAssertEqual(data, receivedValues?.data)
        XCTAssertEqual(response?.statusCode, receivedValues?.response.statusCode)
        XCTAssertEqual(response?.url, receivedValues?.response.url)
    }
    
    func test_shouldGetEmptyDataAndResponseWhenDataIsNil() {
        let response = anyHttpUrlResponse()
        
        let receivedValues = resultWithValues(data: nil, response: response, error: nil)
        
                let emptyData = Data()
                
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(response?.statusCode, receivedValues?.response.statusCode)
        XCTAssertEqual(response?.url, receivedValues?.response.url)
    }
    
    // MARK: Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNonHttpURLResponse() -> URLResponse {
        return URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyHttpUrlResponse() -> HTTPURLResponse? {
        return HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    }
    
    fileprivate func anyError() -> Error {
        return NSError(domain: "any error", code: 1)
    }
    
    private func resultWithError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch receivedResult {
        case let .failure(receivedError as NSError):
            return receivedError
        default:
            XCTFail("Expected failure, got \(receivedResult) instead", file: file, line: line)
            
            return nil
        }
    }
    
    private func resultWithValues(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch receivedResult {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(receivedResult) instead", file: file, line: line)
            
            return nil
        }
            
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        
        let url = makeURL()
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        
        sut.get(from: url) { result in
            receivedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(error: error, data: data, response: response)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
            
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else {
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
        
    }
}
