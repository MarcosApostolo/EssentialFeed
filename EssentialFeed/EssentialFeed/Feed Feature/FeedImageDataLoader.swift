//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 27/12/23.
//
import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {    
    func loadImageData(from url: URL) throws -> Data
}
