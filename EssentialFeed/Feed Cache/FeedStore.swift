//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 13/12/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
