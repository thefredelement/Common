//: Playground - noun: a place where people can play

import UIKit


extension UIDevice {
    func isSimulator() -> Bool {
        var isSim = false
        #if arch(i386) || arch(x86_64) && !os(OSX)
            isSim = true
        #endif
        return isSim
    }
}