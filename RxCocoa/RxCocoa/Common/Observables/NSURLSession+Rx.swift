//
//  NSURLSession+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

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
    public func rx_response(request: NSURLRequest) -> Observable<(NSData!, NSURLResponse!)> {
        return create { observer in
            
            // smart compiler should be able to optimize this out
            var d: NSDate?
            
            if Logging.URLRequests(request) {
                d = NSDate()
            }
            
            let task = self.dataTaskWithRequest(request) { (data, response, error) in
                
                if Logging.URLRequests(request) {
                    let interval = NSDate().timeIntervalSinceDate(d ?? NSDate())
                    println(convertURLRequestToCurlCommand(request))
                    println(convertResponseToString(data, response, error, interval))
                }
                
                if data == nil || response == nil {
                    sendError(observer, error ?? UnknownError)
                }
                else {
                    sendNext(observer, (data, response))
                    sendCompleted(observer)
                }
            }
            
            task.resume()
                
            return AnonymousDisposable {
                task.cancel()
            }
        }
    }
    
    public func rx_data(request: NSURLRequest) -> Observable<NSData> {
        return rx_response(request) >- mapOrDie { (data, response) -> RxResult<NSData> in
            if let response = response as? NSHTTPURLResponse {
                if 200 ..< 300 ~= response.statusCode {
                    return success(data!)
                }
                else {
                    return failure(rxError(.NetworkError, "Server returned failure", [RxCocoaErrorHTTPResponseKey: response]))
                }
            }
            else {
                rxFatalError("response = nil")
                
                return failure(UnknownError)
            }
        }
    }
    
    public func rx_JSON(request: NSURLRequest) -> Observable<AnyObject!> {
        return rx_data(request) >- mapOrDie { (data) -> RxResult<AnyObject!> in
            var serializationError: NSError?
            let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &serializationError)
            
            if let result: AnyObject = result {
                return success(result)
            }
            else {
                return failure(serializationError!)
            }
        }
    }
    
    public func rx_JSON(URL: NSURL) -> Observable<AnyObject!> {
        return rx_JSON(NSURLRequest(URL: URL))
    }
}