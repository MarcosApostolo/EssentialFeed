//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 22/12/23.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        
        self.loader = loader
    }
    
    override func viewDidLoad() {
        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoadLoadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCount = loadCount + 1
        }
    }
}
