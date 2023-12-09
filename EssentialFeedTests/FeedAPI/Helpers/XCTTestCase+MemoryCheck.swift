//
//  XCTTestCase+MemoryCheck.swift
//  EssentialFeedTests
//
//  Created by Marcos Amaral on 09/12/23.
//

import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
