//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 16/04/24.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    final class FeedLocalizationTests: XCTestCase {
        
        func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
            let table = "ImageComments"
            let bundle = Bundle(for: ImageCommentsPresenter.self)
            
            assertLocalizedKeyAndValuesExist(in: bundle, table)
        }
    }
}
