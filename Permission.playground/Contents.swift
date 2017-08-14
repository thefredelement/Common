//: Playground - noun: a place where people can play

import Foundation
import AVFoundation
import Photos

struct Permission {
    
    // Opens the user's setting app for fast access
    // to allowing device permissiosn if needed
    static func openiOSSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        UIApplication.shared.openURL(url)
    }
    
    // MARK: - Mic
    fileprivate static func requestMicrophonePermission(granted: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio) { (isGranted) in
            granted(isGranted)
        }
    }
    
    fileprivate static func isMicrophonePermitted() -> Bool {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) {
        case .authorized:
            return true
        case .denied, .notDetermined, .restricted:
            return false
        }
    }
    
    static func microphone(permitted: @escaping (Bool) -> Void) {
        switch isMicrophonePermitted() {
        case true:
            permitted(true)
        case false:
            requestMicrophonePermission(granted: { (isMicGranted) in
                permitted(isMicGranted)
            })
        }
    }
    
    // MARK: - Photos
    fileprivate static func requestPhotosPermission(granted: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { (phAuthStatus) in
            DispatchQueue.main.async {
                switch phAuthStatus {
                case .authorized:
                    granted(true)
                case .denied, .notDetermined, .restricted:
                    granted(false)
                }
            }
        }
    }
    
    fileprivate static func isPhotosPermitted() -> Bool {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return true
        case .restricted, .denied, .notDetermined:
            return false
        }
    }
    
    /// Asynchrously attempts to gain permission to user photos.
    static func photos(permitted: @escaping (Bool) -> Void) {
        switch isPhotosPermitted() {
        case true:
            permitted(true)
        case false:
            requestPhotosPermission(granted: { (isPhotosGranted) in
                permitted(isPhotosGranted)
            })
        }
    }
    
    // MARK: - Video
    fileprivate static func requestVideoPermission(granted: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (isGranted) in
            DispatchQueue.main.async {
                granted(isGranted)
            }
        }
    }
    
    fileprivate static func isVideoPermitted() -> Bool {
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            return true
        case .denied, .notDetermined, .restricted:
            return false
        }
    }
    
    /// Asynchrously attempts to gain permission to the camera in video mode.
    static func camera(permitted: @escaping (Bool) -> Void) {
        switch isVideoPermitted() {
        case true:
            permitted(true)
        case false:
            requestVideoPermission(granted: { (isVideoGranted) in
                permitted(isVideoGranted)
            })
        }
    }
}
