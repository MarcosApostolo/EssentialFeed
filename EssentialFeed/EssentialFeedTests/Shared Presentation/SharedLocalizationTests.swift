//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 15/04/24.
//

import XCTest
@testable import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<String, DummyView>.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
    // MARK: - Helpers
    private class DummyView: ResourceView {
        typealias ResourceViewModel = String
        
        func display(_ viewModel: String) {
            
        }
    }
}
