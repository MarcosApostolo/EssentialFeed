//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 27/12/23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
