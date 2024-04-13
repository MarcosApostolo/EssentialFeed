//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Marcos Amaral on 13/04/24.
//

import UIKit

extension UIView {
     func enforceLayoutCycle() {
         layoutIfNeeded()
         RunLoop.current.run(until: Date())
     }
 }
