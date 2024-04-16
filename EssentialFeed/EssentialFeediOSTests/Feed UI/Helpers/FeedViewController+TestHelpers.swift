//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 27/12/23.
//
import UIKit
import EssentialFeediOS

extension ListViewController {
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    private var feedImageSection: Int {
        0
    }
    
    var errorMessage: String? {
        errorView?.message
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        
        let ds = tableView.dataSource
        
        let index = IndexPath(row: row, section: feedImageSection)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func simulateErrorViewTap() {
        errorView?.button.simulateTap()
    }
}

extension ListViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
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
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlForiOS17Support()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
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
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
}
