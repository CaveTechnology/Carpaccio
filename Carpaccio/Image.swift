//
//  Image.swift
//  Trimmer
//
//  Created by Matias Piipari on 07/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Cocoa

public enum ImageError:ErrorType {
    case URLMissing
    case URLHasNoPath(NSURL)
    case LocationNotEnumerable(NSURL)
    case LoadingFailed(underlyingError:ErrorType)
}

public class Image {
    public let name:String
    public var thumbnailImage:NSImage? = nil
    public let backingImage:NSImage?
    public let URL:NSURL?
    
    public typealias DistanceFunction = (a:Image, b:Image)-> Double
    
    public required init(image:NSImage) {
        self.backingImage = image
        self.name = image.name() ?? "Untitled"
        self.URL = nil
    }
    
    public init(URL:NSURL) {
        self.URL = URL
        self.name = URL.lastPathComponent ?? "Untitled"
        self.backingImage = nil
    }
    
    public var placeholderImage:NSImage {
        return NSImage(named: "ImagePlaceholder")!
    }
    
    public var presentedImage:NSImage {
        return backingImage ?? self.thumbnailImage ?? self.placeholderImage
    }
    
    public func fetchThumbnail(store:Bool = true, completionHandler:(image:NSImage)->Void, errorHandler:(ErrorType)->Void) {
        if let thumb = self.thumbnailImage {
            completionHandler(image: thumb)
            return
        }
        
        if let url = self.URL {
            let converter:RAWConverter
            do {
                converter = try RAWConverter(URL: url)
            }
            catch {
                errorHandler(error)
                return
            }
            
            converter.decodeWithThumbnailHandler({ thumb in
                if store {
                    self.thumbnailImage = thumb
                }
                completionHandler(image:thumb)
                }) { err in
                    errorHandler(err)
                    return
                }
        }
        else {
            errorHandler(ImageError.URLMissing)
            return
        }
    }
    
    public class var imageFileExtensions:Set<String> {
        return Set(["arw", "nef", "cr2"])
    }
    
    public typealias LoadHandler = (index:Int, total:Int, image:Image) -> Void
    public typealias LoadErrorHandler = (ImageError) -> Void
    
    public class func loadImagesAsynchronously(contentsOfURL URL:NSURL, loadHandler:LoadHandler? = nil, errorHandler:LoadErrorHandler) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            do {
                try loadImages(contentsOfURL: URL, loadHandler: loadHandler)
            }
            catch {
                errorHandler(.LoadingFailed(underlyingError: error))
            }
        }
    }
    
    public class func loadImages(contentsOfURL URL:NSURL, loadHandler:LoadHandler? = nil) throws -> [Image] {
        let fileManager = NSFileManager.defaultManager()
        
        guard let path = URL.path else {
            throw ImageError.URLHasNoPath(URL)
        }
        
        guard let enumerator = fileManager.enumeratorAtPath(path) else {
            throw ImageError.LocationNotEnumerable(URL)
        }
        
        var images = [Image]()
        
        var i = 0
        
        let allPaths = enumerator.allObjects
        for elementStr in allPaths as! [NSString] {
            let pathExtension = elementStr.pathExtension.lowercaseString
            if !Image.imageFileExtensions.contains(pathExtension) {
                continue
            }
            
            let absoluteURL = URL.URLByAppendingPathComponent(elementStr as String)
            let image = Image(URL: absoluteURL)
            
            loadHandler?(index: i, total:allPaths.count, image: image)
            i += 1
            
            images.append(image)
        }
        
        return images
    }
}