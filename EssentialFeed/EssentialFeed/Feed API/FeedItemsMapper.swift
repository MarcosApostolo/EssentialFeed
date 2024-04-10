//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 07/12/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
        
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

