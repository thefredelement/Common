//: Playground - noun: a place where people can play

import UIKit
import ImageIO

/**
 * Provide commonly used ImageIO configurations with neat abstraction
 */
struct ImageIOUtilities {
    
    static func getThumbnailFrom(url: URL, forPixelSize pixelSize: CGFloat) -> UIImage? {
        
        guard
            let thumbURL = CFURLCreateWithFileSystemPath(
                nil,
                url.path as CFString,
                .cfurlposixPathStyle,
                false),
            let imgSrc = CGImageSourceCreateWithURL(
                thumbURL,nil) else {
                    return nil
        }
        
        let options: [NSString: NSObject] = [
            kCGImageSourceThumbnailMaxPixelSize: pixelSize * UIScreen.main.scale as NSObject,
            kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject
        ]
        
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(
            imgSrc,
            0,
            options as CFDictionary) else {
                return nil
        }
        
        return UIImage(cgImage: thumbnail)
    }
    
}
