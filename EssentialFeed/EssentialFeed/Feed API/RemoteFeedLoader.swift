//
//  FeedAPI.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 05/12/23.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(client: client, url: url, mapper: FeedItemMapper.map)
    }
}
