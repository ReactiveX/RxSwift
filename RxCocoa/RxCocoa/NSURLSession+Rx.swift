//
//  NSURLSession+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

func escapeTerminalString(value: String) -> String {
    return value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options: NSStringCompareOptions.allZeros, range: nil)
}

func convertURLRequestToCurlCommand(request: NSURLRequest) -> String {
    let method = request.HTTPMethod ?? "GET"
    var returnValue = "curl -i -v -X \(method) "
        
    if  request.HTTPMethod == "POST" && request.HTTPBody != nil {
        let maybeBody = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding) as? String
        if let body = maybeBody {
            returnValue += "-d \"\(maybeBody)\""
        }
    }
    
    for (key, value) in request.allHTTPHeaderFields ?? [:] {
        let escapedKey = escapeTerminalString((key as? String) ?? "")
        let escapedValue = escapeTerminalString((value as? String) ?? "")
        returnValue += "-H \"\(escapedKey): \(escapedValue)\" "
    }
    
    let URLString = request.URL?.absoluteString ?? "<unkown url>"
    
    returnValue += "\"\(escapeTerminalString(URLString))\""
    
    return returnValue
}

func convertResponseToString(data: NSData!, response: NSURLResponse!, error: NSError!, interval: NSTimeInterval) -> String {
    let ms = Int(interval * 1000)
    
    if let response = response as? NSHTTPURLResponse {
        if 200 ..< 300 ~= response.statusCode {
            return "Success (\(ms)ms): Status \(response.statusCode)"
        }
        else {
            return "Failure (\(ms)ms): Status \(response.statusCode)"
        }
    }

    if let error = error {
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            return "Cancelled (\(ms)ms)"
        }
        return "Failure (\(ms)ms): NSError > \(error)"
    }
    
    return "<Unhandled response from server>"
}

extension NSURLSession {
    public func rx_observableRequest(request: NSURLRequest) -> Observable<(NSData!, NSURLResponse!, NSError!)> {
        return create { observer in
            
            // smart compiler should be able to optimize this out
            var d: NSDate!
            
            if Logging.URLRequests {
                d = NSDate()
            }
            
            let task = self.dataTaskWithRequest(request) { (data, response, error) in
                
                if Logging.URLRequests {
                    let interval = NSDate().timeIntervalSinceDate(d)
                    println(convertURLRequestToCurlCommand(request))
                    println(convertResponseToString(data, response, error, interval))
                }
                
                handleObserverResult(observer.on(.Next(Box(data, response, error))))
                handleObserverResult(observer.on(.Completed))
            }
            
            task.resume()
                
            return success(AnonymousDisposable {
                task.cancel()
            })
        }
    }
    
    public func rx_observableDataRequest(request: NSURLRequest) -> Observable<Result<NSData>> {
        return rx_observableRequest(request) >- map { (data, response, e) -> Result<NSData> in
            if e != nil {
                return .Error(e)
            }
            
            if let response = response as? NSHTTPURLResponse {
                if 200 ..< 300 ~= response.statusCode {
                    return success(data!)
                }
                else {
                    return .Error(rxError(.NetworkError, "Server return failure", [RxCocoaErrorHTTPResponseKey: response]))
                }
            }
            else {
                rxFatalError("response = nil")
                
                return .Error(UnknownError)
            }
        }
    }
    
    public func rx_observableJSONWithRequest(request: NSURLRequest) -> Observable<Result<AnyObject!>> {
        return rx_observableDataRequest(request) >- map { (maybeData) -> Result<AnyObject!> in
            maybeData >== { data in
                var serializationError: NSError?
                let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &serializationError)
                
                if let result: AnyObject = result {
                    return success(result)
                }
                else {
                    return .Error(serializationError!)
                }
            }
        }
    }
    
    public func rx_observableJSONWithURL(URL: NSURL) -> Observable<Result<AnyObject!>> {
        return rx_observableJSONWithRequest(NSURLRequest(URL: URL))
    }
}