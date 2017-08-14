//: Playground - noun: a place where people can play

import Foundation


/**
 
 Provides a base aysnchronous operation subclass of SOperation.
 
 */
class AsyncOperation: Operation {
    
    /// Supports the operations state and sets up
    /// KVO values for OperationQueue
    enum State: String {
        
        case Ready, Executing, Finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue
        }
    }
    
    /// Holds state of the operation
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
}

// MARK: - Extension
// Override super to be async friendly
extension AsyncOperation {
    
    override open var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override open var isExecuting: Bool {
        return state == .Executing
    }
    
    override open var isFinished: Bool {
        return state == .Finished
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    override open func start() {
        
        if isCancelled {
            state = .Finished
            return
        }
        
        main()
        state = .Executing
    }
    
    override open func cancel() {
        state = .Finished
        
    }
    
}