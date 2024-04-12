//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by Marcos Amaral on 11/04/24.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primaryLoader: FeedImageDataLoader
    let fallbackLoader: FeedImageDataLoader
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {

        }
    }

    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryLoader = primary
        self.fallbackLoader = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        let _ = primaryLoader.loadImageData(from: url, completion: completion)
        
        return Task()
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        
        let _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedImageURLs.isEmpty)
        XCTAssertTrue(fallbackLoader.loadedImageURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        
        let url = anyURL()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedImageURLs, [url])
        XCTAssertTrue(fallbackLoader.loadedImageURLs.isEmpty)
    }
    
    // Helpers
    class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            messages.append((url, completion))
            
            return Task()
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
}
