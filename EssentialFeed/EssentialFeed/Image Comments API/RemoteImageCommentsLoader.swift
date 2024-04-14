//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 14/04/24.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
    }
}
