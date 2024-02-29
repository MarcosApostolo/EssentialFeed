//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 29/02/24.
//

import UIKit

extension UIRefreshControl {
    func update(isLoading: Bool) {
        isLoading ? self.beginRefreshing() : self.endRefreshing()
    }
}
