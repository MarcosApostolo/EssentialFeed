//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 27/12/23.
//
import UIKit
import EssentialFeediOS

extension FeedViewController {
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    private var feedImageSection: Int {
        0
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        
        let index = IndexPath(row: row, section: feedImageSection)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension FeedViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
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
        
        feedRefreshViewController?.view = fake
        
        refreshControl = fake
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
}
