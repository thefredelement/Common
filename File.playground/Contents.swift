//: Playground - noun: a place where people can play

import Foundation

extension FileManager {
    
    /**
     Determines if a directory exists using the path of the specified URL.
     
     - parameter url: The URL where the directory may exist.
     */
    class func directoryExistsAt(url: URL) -> Bool {
        
        let path = url.path
        var exists: ObjCBool = false
        
        FileManager.default.fileExists(
            atPath: path,
            isDirectory: &exists)
        
        return exists.boolValue
    }
    
    /**
     Creates a directory at the specified URL
     
     - parameter url: The URL where the directory should be created.
     */
    class func createDirectoryAt(url: URL) {
        
        do {
            
            try FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: false,
                attributes: nil)
            
        } catch let error as NSError {
            
            let desc = "Failed to create directory with error: \(error.localizedDescription)"
        }
    }
    
    // Gets the size of a file at a specific url
    func fileSizeAtPath(_ path: String) -> Int64 {
        
        do {
            
            let fileAttributes  = try attributesOfItem(atPath: path)
            let fileSizeNumber  = fileAttributes[FileAttributeKey.size]
            let fileSize        = (fileSizeNumber as AnyObject).int64Value
            return fileSize!
            
        } catch let error as NSError {
            
            let desc = "Could not get attributes of file at path, with error: \(error.localizedDescription)\nuser info: \(error.userInfo)"
            
            return 0
        }
    }
    
    // Gets the size of a folder
    func folderSizeAtPath(_ path: String) -> Int64 {
        
        var size: Int64 = 0
        
        do {
            
            let files = try subpathsOfDirectory(atPath: path)
            for i in 0..<files.count {
                
                size += fileSizeAtPath(path + "/" + files[i])
            }
            
        } catch let error as NSError {
            
            let desc = "Could not get size of folder with error: \(error.localizedDescription)\n user info: \(error.userInfo)"
        }
        
        return size
    }
    
}
