//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 29/02/24.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
