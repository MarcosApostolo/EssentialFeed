//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 16/12/23.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = imageURL
    }
}
