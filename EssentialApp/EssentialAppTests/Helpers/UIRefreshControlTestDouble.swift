//
//  UIRefreshControlTestDouble.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 27/12/23.
//

import UIKit

class UIRefreshControlTestDouble: UIRefreshControl {
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
