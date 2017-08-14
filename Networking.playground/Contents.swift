//: Playground - noun: a place where people can play

import Foundation

enum URLRequestMethod {
    
    case options, get, head, post, put, patch, delete, trace, connect
    
    var httpMethod: String {
        switch self {
        case .connect:
            return "CONNECT"
        case.delete:
            return "DELETE"
        case .get:
            return "GET"
        case .head:
            return "HEAD"
        case .options:
            return "OPTIONS"
        case .patch:
            return "PATCH"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .trace:
            return "TRACE"
        }
    }
    
}

struct NetworkDataProvider {
    
    // MARK: - Properties
    fileprivate static var downloadingURLs: [URL] = []
    fileprivate static var accessDownloadingURLsQueue = DispatchQueue(label: "downloadingURLsAccess")
    
    fileprivate static func getDictionaryFromJSON(data: Data) -> [String: Any]? {
        
        do {
            
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return json as? [String: Any]
            
        } catch {
            
            let desc = "Could not cast data into foundation key value pair"
            print(desc)
            return nil
        }
    }
    
    
    // Create a list of key value pairs to be used to generated URLQueryItems
    //
    // - parameter key:   The key of the query component.
    // - parameter value: The value of the query component.
    //
    // - returns: An array of tuples containing key value pairs.
    fileprivate static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
            
        } else if let array = value as? [Any] {
            
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
            
        } else if let value = value as? NSNumber {
            
            if value.isBool {
                
                components.append((key, value.boolValue ? "1" : "0"))
                
            } else {
                
                components.append((key, "\(value)"))
            }
            
        } else if let bool = value as? Bool {
            
            components.append((key, bool ? "1" : "0"))
            
        } else {
            
            components.append((key, "\(value)"))
        }
        
        return components
    }
    
    // builds a URLRequest with the specified parameters & method
    fileprivate static func makeURLRequest(url: URL, method: URLRequestMethod, parameters: [String: Any]? = nil) -> URLRequest? {
        
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 5)
        
        // request settings
        request.allowsCellularAccess = true
        request.httpMethod = method.httpMethod
        
        switch method {
            
        case .get:
            
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false), let parameters = parameters {
                
                components.queryItems = []
                parameters.forEach {
                    
                    let pair = queryComponents(fromKey: $0.key, value: $0.value)
                    if let value = pair.first?.1 {
                        
                        let queryItem = URLQueryItem(name: $0.key, value: value)
                        components.queryItems?.append(queryItem)
                    }
                }
                
                request.url = components.url
                return request
            }
            
            return request
            
        default:
            
            if let data = try? JSONSerialization.data(
                withJSONObject: parameters ?? [: ],
                options: .init(rawValue: 0)) {
                
                request.httpBody = data
            }
            
            return request
        }
    }
    
    /**
     
     Sends a network request to the specified URL using the specified method with the (optional) specified paramaters. URL encoding is determined by the method used to make the request.
     
     - Parameter url: The url where the request should be made.
     - Parameter method: The url request method that should be used.
     - Parameter parameters: Optional. The parameters that should be attached to the url request.
     - Parameter headers: Optional. The caller may supply it's own headers, if any are supplied the default headers will not be used.
     - Parameter completion: Optional. Any data received from the network request is converted to JSON then to a top level foundation data object. The caller should be aware of the schema for parsing this data.
     
     */
    static func request(url: URL, method: URLRequestMethod, parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping (_ result: [String: Any]?) -> Void = { _ in }) {
        
        // build the request
        guard var request = makeURLRequest(url: url, method: method, parameters: parameters) else {
            
            let desc = "Could not create URL request"
            print(desc)
            completion(nil)
            return
        }
        
        // set headers, if not are provided a default is used
//        request.allHTTPHeaderFields = [:]
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (taskData, response, error) in
            
            guard let data = taskData else {
                completion(nil)
                // process responses that should be handled
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 401:
                        break
                    case 403:
                        break
                    case 406, 410:
                        break
                    default:
                        break
                    }
                }
                return
            }
            completion(getDictionaryFromJSON(data: data))
        }
        task.resume()
    }
    
    fileprivate static func doesDownloadingURLsContain(url: URL) -> Bool {
        
        var contains = false
        accessDownloadingURLsQueue.sync {
            
            contains = downloadingURLs.contains(url)
        }
        return contains
    }
    
    fileprivate static func addDownloading(url: URL) {
        
        accessDownloadingURLsQueue.sync {
            downloadingURLs.append(url)
        }
    }
    
    fileprivate static func removeDownloading(url: URL) {
        
        accessDownloadingURLsQueue.sync {
            
            if let index = downloadingURLs.index(of: url) {
                downloadingURLs.remove(at: index)
            }
        }
    }
    
    fileprivate static func moveItem(from: URL, to: URL) {
        
        do {
            
            try FileManager.default.moveItem(at: from, to: to)
            
        } catch let error as NSError {
            
            print("Could not move from system temporary url to app temporary url with error: \(error.localizedDescription)\ninfo: \(error.userInfo)")
        }
    }
    
    fileprivate static func getFiletypeFrom(url: URL) -> String? {
        if let fileExtension = url.lastPathComponent.characters.split(separator: ".").last {
            return String(fileExtension)
        }
        return nil
    }
    
    /**
     Saves a file at the specified URL to a local temporary file. The temporary file is removed automatically
     and gives no indiciation of the file type. The caller must take care to move/save the temporary url if desired.
     
     - parameter url:               The remote URL to save.
     - parameter completionHandler: Optional. If successful, the local temporary URL.
     */
    static func download(url sourceURL: URL, completionHandler: @escaping (_ tempLocalURL: URL?) -> ()) {
        
        // do not download urls that already in the progress of being downloaded
        guard doesDownloadingURLsContain(url: sourceURL) == false else {
            completionHandler(nil)
            return
        }
        
        addDownloading(url: sourceURL)
        
        let session = URLSession.shared
        let task = session.downloadTask(with: sourceURL, completionHandler: { (taskURL, _, _) in
            
            guard let localURL = taskURL else {
                
                print("Could not get local temporary iOS url from download task")
                removeDownloading(url: sourceURL)
                completionHandler(nil)
                return
            }
            
            // iOS will remove these downloaded URLs aggressively
            // for safety they are moved to a sandboxed temp
            // diredtory and that temporrary url is returned
            
            let tempFolder = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            var tempFilename: String {
                if let fileExtension = getFiletypeFrom(url: sourceURL) {
                    return UUID().uuidString + "." + fileExtension
                }
                return UUID().uuidString + ".tmp"
            }
            let tempPath = tempFolder.appendingPathComponent(tempFilename, isDirectory: false)
            moveItem(from: localURL, to: tempPath)
            completionHandler(tempPath)
            removeDownloading(url: sourceURL)
        })
        
        task.resume()
    }
    
    private static func createVideoUploadSession(delegate: URLSessionDelegate) -> URLSession {
        
        let config = URLSessionConfiguration.background(withIdentifier: "com.fredfaust.video-upload")
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        return session
    }
    
    private static func makeBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private static func makeUploadPreAndPostDatas(boundary: String, uploadType: UploadType, field: String, filename: String) -> (prefix: Data, append: Data)? {
        
        // converts strings into data
        // to be saved into a local file
        // with a local media file
        // to create the http body of a URLSession uploadTask w/file
        
        // create prefix data from strings
        var rawPrefixData = Data()
        
        if
            let partA = "--\(boundary)\r\n".data(using: String.Encoding.utf8),
            let partB = "Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8),
            let partC = "Content-Type: \(uploadType.mime)\r\n\r\n".data(using: String.Encoding.utf8) {
            
            [partA, partB, partC].forEach {
                rawPrefixData.append($0) }
            
        }
        
        let prefix: Data = rawPrefixData
        
        // generate appened data
        var rawAppendData = Data()
        
        if
            let partA = "\r\n".data(using: String.Encoding.utf8),
            let partB = "--\(boundary)--\r\n".data(using: String.Encoding.utf8) {
            
            [partA, partB].forEach { rawAppendData.append($0) }
            
        }
        
        let append: Data = rawAppendData
        
        if prefix.count > 0 && append.count > 0 {
            
            return (prefix: prefix, append: append)
        }
        
        return nil
    }
    
    fileprivate static func getUploadTypeFrom(url: URL) -> UploadType? {
        
        let lastComponent = url.lastPathComponent
        
        if lastComponent.contains(UploadType.jpeg.fileExtension) || lastComponent.contains("jpeg") {
            return UploadType.jpeg
        }
        
        if lastComponent.contains(UploadType.png.fileExtension) {
            return UploadType.png
        }
        
        if lastComponent.contains(UploadType.quickTime.fileExtension) {
            return UploadType.quickTime
        }
        return nil
    }
    
    /**
     Uploads a local URL to the utility/image end point. This is an asynchronous upload and does not handle background uploading. The local URL should have a file extension that accurately describes the file so a proper upload file type can be used.
     
     - parameter type: The UploadType (quicktime, jpeg or png)
     - paramter url: The local URL containing the PNG image data, must be a 'file://' URL
     - remoteURL: Optional, A URL representing the image's location on the World Wide Web.
     
     */
    static func upload(to url: URL, usingParameter parameter: String, fromLocalURL localURL: URL, remoteURL: @escaping (URL?) -> Void) {
        
        let boundary = makeBoundary()
        
        guard
            let uploadType = getUploadTypeFrom(url: localURL),
            let datas = makeUploadPreAndPostDatas(boundary: boundary, uploadType: uploadType, field: parameter, filename: "image\(uploadType.fileExtension)"),
            let uploadFile = try? streamedFileCopy(from: localURL, prefixData: datas.prefix, appendData: datas.append),
            let urlToUpload = uploadFile else {
                print("Could not get required properties for file upload")
                remoteURL(nil)
                return
        }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // a good place to add headers
        
        let task = session.uploadTask(with: request, fromFile: urlToUpload) { (apiData, response, error) in
            
            guard
                let responseData = apiData,
                let data = getDictionaryFromJSON(data: responseData) else {
                    print("Could not get data from api response when trying to upload an image, with response: \(String(describing: apiData))")
                    remoteURL(nil)
                    return
            }
            
            // handle success
            
//            if let responseURL = URL(string: String.from(data, atKey: "url") ?? String.from(data, atKey: "avatar") ?? "") {
//                
//                remoteURL(responseURL)
//                return
//            }
            
            print("Upload image operation has failed, response data: \(String(describing: apiData))")
            remoteURL(nil)
            
        }
        
        task.resume()
    }
    
    /**
     Uploads video file at the specified location. This upload will use a background url session if neccessary. Callers should manage queues and pending uploads as required.
     
     - parameter url: The local url of the video file.
     - parameter delegate: The NSURLSessionDelegate that will be responsible for handling task completion as well as various other delegate methods.
     - parameter completion: The block that will be executed after the upload has completed.
     
     - returns: The Int returned is the ID of the upload task. The caller may use this to track upload progress for a specific task.
     
     */
    static func uploadVideoFrom(url localVideoURL: URL, usingDelegate delegate: URLSessionDelegate) throws -> Int {
        
        let boundary = makeBoundary()
        
        let rawHost = "https://www.somewebsite"
        
        guard
            let url = URL(string: rawHost + "anEndpoint"),
            let datas = makeUploadPreAndPostDatas(boundary: boundary, uploadType: .quickTime, field: "video", filename: "video\(UploadType.quickTime.fileExtension)") else {
                
                throw UploadVideoError.couldNotCreatePrefixAndAppendData
        }
        
        guard
            let localURL = try? streamedFileCopy(from: localVideoURL, prefixData: datas.prefix, appendData: datas.append),
            let urlToUpload = localURL else {
                
                throw UploadVideoError.couldNotStreamCopyLocalData
        }
        
        let session = createVideoUploadSession(delegate: delegate)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let task = session.uploadTask(with: request, fromFile: urlToUpload)
        
        task.resume()
        return task.taskIdentifier
    }
    
    private static func createLocalTempFile() -> URL? {
        
        let dir = NSTemporaryDirectory()
        let filename = UUID().uuidString + ".tmp"
        
        return URL(fileURLWithPath: dir + filename)
        
    }
    
    fileprivate static func streamedFileCopy(from srcURL: URL, prefixData: Data, appendData: Data) throws -> URL? {
        
        guard let dstURL = createLocalTempFile(),
            let src = InputStream(url: srcURL),
            let dst = OutputStream(url: dstURL, append: false) else {
                return nil
        }
        
        src.open()
        dst.open()
        defer {
            src.close()
            dst.close()
        }
        
        try dst.write(prefixData)
        
        repeat {
            let d = try src.read(maxCount: 65536)
            if d.isEmpty {
                break
            }
            try dst.write(d)
        } while true
        
        try dst.write(appendData)
        
        src.close()
        dst.close()
        
        return dstURL
    }
    
}

fileprivate extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

fileprivate extension InputStream {
    
    /// Reads data from a stream.
    ///
    /// - parameter maxCount: The maximum amount of data to read.
    ///
    /// - throws: If the read fails with an error.
    ///
    /// - returns: The amount of data read; this will will be less than
    ///     `maxCount` only if the read hits the end of the file.
    
    func read(maxCount: Int) throws -> Data {
        precondition(maxCount > 0)
        var result = Data(count: maxCount)
        let actualCount = try result.withUnsafeMutableBytes { (base: UnsafeMutablePointer<UInt8>) throws -> Int in
            var offset = 0
            while offset < maxCount {
                let bytesRead = self.read(base + offset, maxLength: maxCount - offset)
                if bytesRead > 0 {
                    offset += bytesRead
                } else if bytesRead == 0 {
                    break
                } else {
                    throw self.streamError!
                }
            }
            return offset
        }
        result.removeSubrange(actualCount..<result.count)
        return result
    }
}

fileprivate extension OutputStream {
    
    /// Writes data to a stream.
    ///
    /// This will either write all the data or throw an error.
    ///
    /// - parameter data: The data to write.
    ///
    /// - throws: If the write fails with an error.
    
    func write(_ data: Data) throws {
        let maxCount = data.count
        try data.withUnsafeBytes { (base: UnsafePointer<UInt8>) throws in
            var offset = 0
            while offset < maxCount {
                let bytesWritten = self.write(base, maxLength: maxCount - offset)
                if bytesWritten > 0 {
                    offset += bytesWritten
                } else if bytesWritten == 0 {
                    fatalError()
                } else {
                    throw self.streamError!
                }
            }
        }
    }
}

enum UploadVideoError: Error {
    
    case couldNotStreamCopyLocalData
    case couldNotCreatePrefixAndAppendData
    
    var localErrorDescription: String {
        
        switch self {
            
        case .couldNotStreamCopyLocalData:
            
            return "Could not copy local video file to new file with prefix and append data"
            
        case .couldNotCreatePrefixAndAppendData:
            
            return "Could not create prefix and append datas from strings"
        }
    }
}



enum UploadType {
    
    case quickTime
    case png
    case jpeg
    
    var fileExtension: String {
        
        switch self {
            
        case .quickTime:
            return ".mov"
            
        case .png:
            return "png"
            
        case .jpeg:
            return ".jpg"
        }
    }
    
    var mime: String {
        
        switch self {
        case .quickTime:
            
            return "video/quicktime"
            
        case .png:
            return "image/png"
            
        case .jpeg:
            return "image/jpeg"
        }
        
    }
}
