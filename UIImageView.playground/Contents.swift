//: Playground - noun: a place where people can play

import UIKit
import AVFoundation

extension UIImageView {
    
    fileprivate func getImageScale() -> CGSize? {
        guard let image = image else {
            print("no image, returning nil a")
            return nil
        }
        
        let sx = Double(frame.size.width/image.size.width)
        let sy = Double(frame.size.height/image.size.height)
        var scale = 1.0
        
        switch contentMode {
        case .scaleAspectFit:
            scale = fmin(sx, sy)
            return CGSize(width: scale, height: scale)
        case .scaleAspectFill:
            scale = fmax(sx, sy)
            return CGSize(width: scale, height: scale)
        case .scaleToFill:
            return CGSize(width: sx, height: sy)
        default:
            return CGSize(width: scale, height: scale)
        }
    }
    
    /// returns the size of the image contained in the image view
    var imageSize: CGSize? {
        guard let image = image, let scale = getImageScale() else {
            print("no image, returning nil b")
            return nil
        }
        let width = image.size.width*scale.width
        let height = image.size.height*scale.height
        return CGSize(width: width, height: height)
    }
    
    /// Returns the frame of the image as long as
    /// the views content mode is scaleAspectFit
    var imageFrame: CGRect? {
        guard contentMode == .scaleAspectFit else {
            print("INCORRECT CONTENT MODE")
            return nil
        }
        
        return AVMakeRect(aspectRatio: image?.size ?? CGSize.zero, insideRect: bounds)
        
    }
    
    /// Returns the pixel size needed for the image based on the pixel density
    /// of the current device
    var pixelSize: CGFloat {
        return max(frame.size.width,frame.size.height)*UIScreen.main.scale
    }
    
}
