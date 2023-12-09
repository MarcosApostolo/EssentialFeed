//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 07/12/23.
//

import Foundation

internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [APIFeedItem]
        
        var feed: [FeedItem] {
            return items.map { $0.feedItem }
        }
    }

    private struct APIFeedItem: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
            guard response.statusCode == OK_200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
            }

            return .success(root.feed)
        }
}


