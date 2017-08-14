//: Playground - noun: a place where people can play

import UIKit


extension UIScrollView {
    /// A computed page number will return the current page
    /// based on 0, for this scroll view. If paging is not enabled
    /// 0 is returned
    var pageNumber: Int {
        if isPagingEnabled == false {
            return 0
        }
        return Int(round(contentOffset.x/frame.size.width))
    }
    
    func scroll(toPage page: Int, animated: Bool) {
        setContentOffset(
            CGPoint.init(x: self.frame.width * CGFloat(page), y: 0),
            animated: animated)
    }
}