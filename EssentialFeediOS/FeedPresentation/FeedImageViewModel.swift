//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Marcos Amaral on 03/01/24.
//

import Foundation
import EssentialFeed

public final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private let imageLoader: FeedImageDataLoader
    private let feedImage: FeedImage
    private var task: FeedImageDataLoaderTask?
    private var imageTransformer: (Data) -> Image?
    
    public init(imageLoader: FeedImageDataLoader, feedImage: FeedImage, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.feedImage = feedImage
        self.imageTransformer = imageTransformer
    }
    
    var hasLocation: Bool {
        feedImage.location != nil
    }
    
    var description: String? {
        feedImage.description
    }
    
    var location: String? {
        feedImage.location
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        task = imageLoader.loadImageData(from: feedImage.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
