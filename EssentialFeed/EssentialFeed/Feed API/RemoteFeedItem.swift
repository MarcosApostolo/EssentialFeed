//
//  RemoteFeedImte.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 14/04/24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
