//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 16/12/23.
//

import Foundation

internal final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let maxCacheAgeInDays = 7
    
    private init() {}
    
    public static func validate(
        _ timestamp: Date, against date: Date) -> Bool {
            let calendar = Calendar(identifier: .gregorian)
            
            guard let maxCacheDate = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
                return false
            }
            
            return date < maxCacheDate
        }
}
