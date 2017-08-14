//: Playground - noun: a place where people can play

import Foundation

// BOOL
extension Bool {
    
    /// Will attempt to cast the given instace to a Bool
    ///
    /// - Parameter any: Any element conforming to the Any protocol
    /// - Returns: Optionl. A Bool
    static func from(any: Any) -> Bool? {
        
        switch any {
            
        case let bool as Bool:
            return bool
            
        case let str as String:
            
            if str == "true" {
                return true
            }
            
            if str == "false" {
                return false
            }
            
            return nil
            
        case let num as NSNumber:
            return num.boolValue
            
        default:
            return nil
        }
    }
    
    /// Optionally returns a Bool from the supplied dictionary
    ///
    /// - Parameters:
    ///   - data: The dicitonary where the potential boolean is located
    ///   - key: The key where the boolean may be defined
    /// - Returns: Optional. A Bool
    static func from(_ data: [String: Any], atKey key: String) -> Bool? {
        
        guard let any = data[key] else {
            return nil
        }
        
        return Bool.from(any: any)
    }
}

// NSNumber
extension NSNumber {
    
    class func from(value: Any?) -> NSNumber? {
        switch value {
        case .some(let value):
            switch value {
            case let num as NSNumber:
                return num
            case let str as String:
                return NumberFormatter().number(from: str)
            default:
                return nil
            }
        case .none:
            return nil
        }
    }
    
    /// Optionally returns an NSNumber from the supplied dictionary
    ///
    /// - Parameters:
    ///   - data: The dicitonary where the potential number is located
    ///   - key: The key where the number may be defined
    /// - Returns: Optional. An NSNumber
    class func from(_ data: [String: Any], atKey key: String) -> NSNumber? {
        
        guard let object = data[key] else {
            return nil
        }
        
        switch object {
            
        case let num as NSNumber:
            
            return num
            
        case let str as String:
            
            return NumberFormatter().number(from: str)
            
        default:
            return nil
        }
    }
}

// String
extension String {
    
    static func from(value: Any?) -> String? {
        switch value {
        case .some(let any):
            switch any {
            case let str as String:
                return str
            case let num as NSNumber:
                return "\(num)"
            default:
                return nil
            }
        case .none:
            return nil
        }
    }
    
    /// Optionally returns a String from the supplied dictionary
    ///
    /// - Parameters:
    ///   - data: The dicitonary where the potential string is located
    ///   - key: The key where the string may be defined
    /// - Returns: Optional. A String
    static func from(_ data: [String: Any], atKey key: String) -> String? {
        
        guard let object = data[key] else {
            return nil
        }
        
        switch object {
            
        case let str as String:
            
            return str
            
        case let num as NSNumber:
            
            return NumberFormatter().string(from: num)
            
        default:
            return nil
        }
    }
    
    /// Returns self trimmed for white space and new lines.
    public func trimString() -> String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
}

// URL
extension URL {

    /// Will try to cast the provided value to a string then make a URL from it. If the string isn't able to be used directly an attept at URL encoding the string will be made
    ///
    /// - Parameter from: An optional any
    /// - Returns: If successful, a URL is returned
    static func make(from: Any?) -> URL? {
        if let str = from as? String {
            
            switch URL(string: str) {
            case .some(let url):
                return url
            default:
                return URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
            }
        }
        return nil
    }
}



