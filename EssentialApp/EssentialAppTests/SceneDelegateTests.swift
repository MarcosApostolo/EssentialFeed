//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Marcos Amaral on 12/04/24.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is ListViewController, "Expected a list controller as top view controller, got \(String(describing: topController)) instead")
    }
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }
    
    // Helpers
    private class UIWindowSpy: UIWindow {
      var makeKeyAndVisibleCallCount = 0

      override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount += 1
      }
    }
}
