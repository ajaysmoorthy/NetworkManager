//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Ajay.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import Alamofire

/// Alias for closure that returns a dictionary, used as success closure for network calls
public typealias successClosure = (_ result: [String:AnyObject]) -> Void
/// Alias for closure that returns progress, used as progress closure for network calls
public typealias progressClosure   = (_ progress: Float) -> Void
/// Alias for closure that returns error, used as error closure for network calls
public typealias errorClosure   = (_ error: Error) -> Void

class NetworkManager {
    // MARK: - Private Properties -
    
    
    // MARK: - Public Methods -
    
    /// Performs post request to the given URL
    ///
    /// - Parameters:
    ///   - urlString: URL to which the request to be performed
    ///   - parameters: Parameters for the service (optional)
    ///   - successCB: Success callback closure
    ///   - errorCB: Error callback closure
    class func performPostRequest(toURL urlString:String, andParameters parameters:[String:AnyObject]?, onSuccess successCB:@escaping successClosure, onError errorCB:@escaping errorClosure){
        
        // Validates the URL
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: 404, userInfo: nil)
            errorCB(error as Error)
            return
        }
        
        // Performs post request
        performWebServiceRequestWithPost(toURL: url, andParameters: parameters, onSuccess: successCB, onError: errorCB)
    }
    
    /// Performs get request to the given URL
    ///
    /// - Parameters:
    ///   - urlString: URL to which the request to be performed
    ///   - parameters: Parameters for the service (optional)
    ///   - successCB: Success callback closure
    ///   - errorCB: Error callback closure
    class func performGetRequest(toURL urlString:String, andParameters parameters:[String:AnyObject]?, onSuccess successCB:@escaping successClosure, onError errorCB:@escaping errorClosure){
        
        // Validates the URL
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: 404, userInfo: nil)
            errorCB(error as Error)
            return
        }
        
        // Performs get request
        performWebServiceRequestWithGet(toURL: url, andParameters: parameters, onSuccess: successCB, onError: errorCB)
    }
    
    /// Performs request to upload image to given URL
    ///
    /// - Parameters:
    ///   - urlString: URL to which the request to be performed
    ///   - parameter imageFileURL:   URL for imageFile
    ///   - parameter parameters:  Parameters for the service (optional)
    ///   - parameter success:     Success callback closure
    ///   - parameter errorMethod: error callback closure
    class func performImageUpload(toURL urlString:String, imageFileURL:URL, andParameters parameters:[String:AnyObject]?, onSuccess successCB:@escaping successClosure, onProgress progressCB:@escaping progressClosure, onError errorCB:@escaping errorClosure){
        
        // Validates the URL
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: 404, userInfo: nil)
            errorCB(error as Error)
            return
        }
        
        // Performs image upload request
                performImageUploadRequest(toURL: url, imageURL: imageFileURL, andParameters: parameters, onSuccess: successCB, progressDone: progressCB, onError: errorCB)
    }
    
    
    // MARK: - Private Methods -
    
    /// Private function to performs post request to the given URL
    ///
    /// - Parameters:
    ///   - url: url for the upload image web service
    ///   - method: method of web service
    ///   - parameters: a dictionary of the paramaters to be send
    ///   - successCB: block that is to be executed on success
    ///   - errorCB: block that is to be executed on error condition
    private class func performWebServiceRequestWithPost(toURL url:URL, andParameters parameters:[String:AnyObject]?, onSuccess successCB:@escaping successClosure, onError errorCB:@escaping errorClosure){
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON {
            (response:DataResponse<Any>) in
            switch(response.result){
            case .success(_):
                if let _data = response.result.value as? [String:AnyObject] {
                    successCB(_data)
                }
            case .failure(_):
                if let _error = response.result.error {
                    errorCB(_error)
                }
            }
        }
        
    }
    
    /// Private function to performs post request to the given URL
    ///
    /// - Parameters:
    ///   - url: url for the upload image web service
    ///   - method: method of web service
    ///   - parameters: a dictionary of the paramaters to be send
    ///   - successCB: block that is to be executed on success
    ///   - errorCB: block that is to be executed on error condition
    private class func performWebServiceRequestWithGet(toURL url:URL, andParameters parameters:[String:AnyObject]?, onSuccess successCB:@escaping successClosure, onError errorCB:@escaping errorClosure){
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON {
            (response:DataResponse<Any>) in
            switch(response.result){
            case .success(_):
                if let _data = response.result.value as? [String:AnyObject] {
                    successCB(_data)
                }
            case .failure(_):
                if let _error = response.result.error {
                    errorCB(_error)
                }
            }
        }
        
    }
    
    /// Private function for uploading an image
    ///
    /// - Parameters:
    ///   - url: url for the upload image web service
    ///   - fileURL: URL of File to be uploaed
    ///   - method: method of web service
    ///   - parameters: a dictionary of the paramaters to be send
    ///   - successCB: block that is to be executed on success
    ///   - progressDone: block that is to be executed on progress
    ///   - errorCB: block that is to be executed on error condition
    private class func performImageUploadRequest(toURL url:URL, imageURL:URL, andParameters parameters:[String:AnyObject]?, onSuccess successCB:@escaping successClosure, progressDone:@escaping progressClosure, onError errorCB:@escaping errorClosure){
        
        //if let parameters = parameters {
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageURL, withName: "file")
            },
                to: url,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if let x: AnyObject = response.result.value as AnyObject? {
                                successCB(x as! Dictionary<String, AnyObject>)}
                            else {
                                errorCB(NSError(domain: "Results returned by server illegitimate", code: 1, userInfo: nil))
                            }
                            debugPrint(response)
                        }
                        
                        upload.uploadProgress { progress in
                            let imageLoaded = Double(progress.completedUnitCount)//(totalBytesWritten)
                            let totalImageSize = Double(progress.totalUnitCount)//(totalBytesExpectedToWrite)
                            let imageUpload = Float(imageLoaded/totalImageSize)
                            
                            progressDone(Float(imageUpload))
                            
                        }

                    case .failure(let encodingError):
                        print(encodingError)
                    }
            })
        
    }
    
}
