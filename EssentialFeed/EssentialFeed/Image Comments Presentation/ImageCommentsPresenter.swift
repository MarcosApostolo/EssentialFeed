//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Marcos Amaral on 16/04/24.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the Image Comments view")
    }
}
