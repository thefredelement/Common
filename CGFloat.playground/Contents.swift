//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

extension CGFloat {
    
    /// assuming self represents a degree
    /// that would be a singular
    /// degree in a 360 degree context
    func makeRadian() -> CGFloat {
        return self*(CGFloat.pi/180)
    }
}