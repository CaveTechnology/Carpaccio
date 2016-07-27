//
//  ImageLoading.swift
//  Carpaccio
//
//  Created by Markus Piipari on 27/07/16.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Foundation


public typealias ImageMetadataHandler = (metadata: ImageMetadata) -> Void

public typealias PresentableImageHandler = (image: NSImage, metadata: ImageMetadata) -> Void

public typealias ImageLoadingErrorHandler = (error: ErrorType) -> Void


protocol ImageLoaderProtocol
{
    var imageURL: NSURL { get }
    
    /** Retrieve metadata about this loader's image, to be called before loading actual image data. */
    func extractImageMetadata(handler: ImageMetadataHandler, errorHandler: ImageLoadingErrorHandler)
    
    /** Load thumbnail image. */
    func loadThumbnailImage(handler: PresentableImageHandler, errorHandler: ImageLoadingErrorHandler)
    
    /** Load full-size image. */
    func loadFullSizeImage(handler: PresentableImageHandler, errorHandler: ImageLoadingErrorHandler)
}