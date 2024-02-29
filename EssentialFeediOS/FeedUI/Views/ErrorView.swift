//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 29/02/24.
//

import Foundation
import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!

    public var message: String? {
        get { return label.text }
        set { label.text = newValue }
     }
}
