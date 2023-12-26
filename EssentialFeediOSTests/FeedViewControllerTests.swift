//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 22/12/23.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0, "Expected no load requests before the sut loads")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCount, 1, "Expected one load request when the sut is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCount, 2, "Expected another loading request when the user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCount, 3, "Expected another loading request when the user initiates a load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhenFeedIsLoading() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance(with: {
            XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator when view is loaded")
        })
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected a loading indicator when the view appeared")
        
        loader.completeFeedLoading(at: 0)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator after load completes")
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected a loading indicator after the user initiates a load")
        
        loader.completeFeedLoading(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator after load completes")
    }
    
    // MARK: Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        checkForMemoryLeaks(loader, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        var completions = [(FeedLoader.Result) -> Void]()
        var loadCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))}
        }
    }
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    func simulateAppearance(with loadAction: @escaping () -> Void) {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlForiOS17Support()
            
            loadAction()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlForiOS17Support() {
        let fake = UIRefreshControlTestDouble()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private class UIRefreshControlTestDouble: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool {
        return _isRefreshing
    }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
