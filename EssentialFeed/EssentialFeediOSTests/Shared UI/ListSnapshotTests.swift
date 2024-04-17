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
        let controller = ListViewController()
        controller.simulateAppearance()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func emptyFeed() -> [CellController] {
        []
    }
}

private extension ListViewController {
    func display(errorMessage: String) {
        errorView.message = errorMessage
    }
    
    func display(_ model: [CellController]) {
        tableModel = model
    }
}
