//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 15/04/24.
//

import Foundation

public class FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}
