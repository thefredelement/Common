//: Playground - noun: a place where people can play

import UIKit

extension UIImage {
    /**
     Fixes image orientation
     
     - returns: The properly rotated UIImage.
     */
    func rotate() -> UIImage {
        
        
        // No-op if the orientation is already correct
        if (imageOrientation == UIImageOrientation.up) {
            return self;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (imageOrientation == UIImageOrientation.down
            || imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(CGFloat.pi))
        }
        
        if (imageOrientation == UIImageOrientation.left
            || imageOrientation == UIImageOrientation.leftMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(CGFloat.pi/2))
        }
        
        if (imageOrientation == UIImageOrientation.right
            || imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: CGFloat(-CGFloat.pi/2));
        }
        
        if (imageOrientation == UIImageOrientation.upMirrored
            || imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (imageOrientation == UIImageOrientation.leftMirrored
            || imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard
            let cgImage = cgImage,
            let colorSpace = cgImage.colorSpace,
            let ctx:CGContext = CGContext(data: nil,
                                          width: Int(size.width),
                                          height: Int(size.height),
                                          bitsPerComponent: cgImage.bitsPerComponent,
                                          bytesPerRow: 0,
                                          space: colorSpace,
                                          bitmapInfo: cgImage.bitmapInfo.rawValue) else {
                                            print("Could not rotate image!")
                                            return UIImage()
        }
        
        ctx.concatenate(transform)
        
        if
            (imageOrientation == UIImageOrientation.left
                || imageOrientation == UIImageOrientation.leftMirrored
                || imageOrientation == UIImageOrientation.right
                || imageOrientation == UIImageOrientation.rightMirrored) {
            
            ctx.draw(cgImage, in: CGRect(x:0,y:0,width:size.height,height:size.width))
            
        } else {
            ctx.draw(cgImage, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let cgimg:CGImage = ctx.makeImage() else {
            return UIImage()
        }
        
        return UIImage(cgImage: cgimg)
    }
    
}
