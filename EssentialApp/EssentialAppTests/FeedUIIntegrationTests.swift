//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Marcos Amaral on 22/12/23.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedUIIntegrationTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no load requests before the sut loads")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected one load request when the sut is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request when the user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected another loading request when the user initiates a load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected a loading indicator when the view appeared")
        
        loader.completeFeedLoading(at: 0)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator after load completes")
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected a loading indicator after the user initiates a load")
        
        loader.completeFeedLoading(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator after load completes")
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected a loading indicator after the user initiates a load")
        
        loader.completeFeedLoadingWithError(at: 2)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator after load fails")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image1 = makeImage(description: "a description", location: "a location")
        let image2 = makeImage(description: nil, location: "another location")
        let image3 = makeImage(description: "another description", location: nil)
        let image4 = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image1], at: 0)
        assertThat(sut, isRendering: [image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image1, image2, image3, image4], at: 1)
        assertThat(sut, isRendering: [image1, image2, image3, image4])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let image1 = makeImage(url: URL(string: "https://any-url.com")!)
        let image2 = makeImage(url: URL(string: "https://other-url.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [image1, image2], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let image2 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image1, image2], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image1.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image1.url, image2.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view2?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData1 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData1, at: 0)
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view2?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData2 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData2, at: 1)
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view2?.renderedImage, imageData2, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view2?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view2?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view2?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let image2 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image1, image2], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url, image1.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url, image1.url, image2.url], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let image2 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image1, image2], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let image2 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image1, image2], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image1.url], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image1.url, image2.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_feedImageView_isDisplayedWithAnimation() {
        let (sut, loader) = makeSUT()
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        
        sut.simulateAppearance()
                
        loader.completeFeedLoading(with: [image1])
        
        let cell = sut.simulateFeedImageViewVisible(at: 0)
        
        XCTAssertEqual(cell?.feedImageView.alpha, 0)
        
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertEqual(cell?.feedImageView.alpha, 1)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        let exp = expectation(description: "wait for background queue")
        
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [makeImage()])
        
        sut.simulateFeedImageViewVisible(at: 0)
        
        let exp = expectation(description: "wait for background queue")
        
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData())
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_errorView_doesNotRenderErrorOnLoad() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_feedImageView_reloadsImageURLWhenBecomingVisibleAgain() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        sut.simulateFeedImageBecomingVisibleAgain(at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url], "Expected two image URL request after first view becomes visible again")

        sut.simulateFeedImageBecomingVisibleAgain(at: 1)

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url, image1.url, image1.url], "Expected two new image URL request after second view becomes visible again")
    }
    
    func test_feedImageView_configuresViewCorrectlyWhenCellBecomingVisibleAgain() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])

        let view0 = sut.simulateFeedImageBecomingVisibleAgain(at: 0)

        XCTAssertEqual(view0?.renderedImage, nil, "Expected no rendered image when view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action when view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator when view becomes visible again")

        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 1)

        XCTAssertEqual(view0?.renderedImage, imageData, "Expected rendered image when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator when image loads successfully after view becomes visible again")
    }
    
    func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        view0.prepareForReuse()

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)

        XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
    }
    
    func test_feedImageView_showsDataForNewViewRequestAfterPreviousViewIsReused() throws {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let previousView = try XCTUnwrap(sut.simulateFeedImageViewNotVisible(at: 0))

        let newView = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        previousView.prepareForReuse()

        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 1)

        XCTAssertEqual(newView.renderedImage, imageData)
    }
    
    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])

        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    // MARK: Helpers
    func makeSUT(selection: @escaping (FeedImage) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposeWith(
            feedLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection
        )
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
}
