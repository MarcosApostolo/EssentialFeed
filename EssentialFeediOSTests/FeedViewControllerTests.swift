//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 22/12/23.
//

import XCTest
import EssentialFeed

final class FeedViewController {
    private var loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            
        }
    }
}
