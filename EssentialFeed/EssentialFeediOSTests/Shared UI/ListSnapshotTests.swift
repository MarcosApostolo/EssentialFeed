//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 16/04/24.
//

import XCTest
@testable import EssentialFeed
@testable import EssentialFeediOS

class ListSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_FEED_dark")
    }

    func test_feedWithError() {
        let sut = makeSUT()

        sut.display(errorMessage: "An error message")

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_ERROR_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.simulateAppearance()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
}

private extension ListViewController {
    func display(_ model: [FeedImageCellController]) {
        tableModel = model
    }
    
    func display(errorMessage: String) {
        errorView?.show(message: errorMessage)
    }
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }

        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func prepareForFirstAppearance() {
        replaceRefreshControlForiOS17Support()
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
