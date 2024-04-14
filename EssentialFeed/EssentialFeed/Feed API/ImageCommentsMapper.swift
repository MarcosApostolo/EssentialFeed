//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 14/04/24.
//

import Foundation

internal struct ImageCommentsItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
        
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
