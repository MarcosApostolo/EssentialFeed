//
//  UITableView+CellDequeueing.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 27/02/24.
//

import Foundation
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
