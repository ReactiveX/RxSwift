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
    return value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options:[], range: nil)
}

func convertURLRequestToCurlCommand(request: NSURLRequest) -> String {
    let method = request.HTTPMethod ?? "GET"
    var returnValue = "curl -i -v -X \(method) "

    if  request.HTTPMethod == "POST" && request.HTTPBody != nil {
        let maybeBody = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding) as? String
        if let body = maybeBody {
            returnValue += "-d \"\(body)\""
        }
    }

    for (key, value) in request.allHTTPHeaderFields ?? [:] {
        let escapedKey = escapeTerminalString((key as String) ?? "")
        let escapedValue = escapeTerminalString((value as String) ?? "")
        returnValue += "-H \"\(escapedKey): \(escapedValue)\" "
    }

    let URLString = request.URL?.absoluteString ?? "<unkown url>"

    returnValue += "\"\(escapeTerminalString(URLString))\""

    return returnValue
}

func convertResponseToString(data: NSData!, _ response: NSURLResponse!, _ error: NSError!, _ interval: NSTimeInterval) -> String {
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
    /**
    Observable sequence of responses for URL request.
    
    Performing of request starts after observer is subscribed and not after invoking this method.
    
    **URL requests will be performed per subscribed observer.**
    
    Any error during fetching of the response will cause observed sequence to terminate with error.
    
    - parameter request: URL request.
    - returns: Observable sequence of URL responses.
    */
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
                    print(convertURLRequestToCurlCommand(request))
                    print(convertResponseToString(data, response, error, interval))
                }

                if data == nil || response == nil {
                    observer.on(.Error(error ?? RxError.UnknownError))
                }
                else {
                    observer.on(.Next(data as NSData!, response as NSURLResponse!))
                    observer.on(.Completed)
                }
            }


            let t = task
            t.resume()

            return AnonymousDisposable {
                task.cancel()
            }
        }
    }

    /**
    Observable sequence of response data for URL request.
    
    Performing of request starts after observer is subscribed and not after invoking this method.
    
    **URL requests will be performed per subscribed observer.**
    
    Any error during fetching of the response will cause observed sequence to terminate with error.
    
    If response is not HTTP response with status code in the range of `200 ..< 300`, sequence
    will terminate with `(RxCocoaErrorDomain, RxCocoaError.NetworkError)`.
    
    - parameter request: URL request.
    - returns: Observable sequence of response data.
    */
    public func rx_data(request: NSURLRequest) -> Observable<NSData> {
        return rx_response(request).map { (data, response) -> NSData in
            guard let response = response as? NSHTTPURLResponse else {
                throw RxError.UnknownError
            }
            
            if 200 ..< 300 ~= response.statusCode {
                return data ?? NSData()
            }
            else {
                throw rxError(.NetworkError, message: "Server returned failure", userInfo: [
                    RxCocoaErrorHTTPResponseKey: response,
                    RxCocoaErrorHTTPResponseDataKey: data ?? NSData()
                ])
            }
        }
    }

    /**
    Observable sequence of response JSON for URL request.
    
    Performing of request starts after observer is subscribed and not after invoking this method.
    
    **URL requests will be performed per subscribed observer.**
    
    Any error during fetching of the response will cause observed sequence to terminate with error.
    
    If response is not HTTP response with status code in the range of `200 ..< 300`, sequence
    will terminate with `(RxCocoaErrorDomain, RxCocoaError.NetworkError)`.
    
    If there is an error during JSON deserialization observable sequence will fail with that error.
    
    - parameter request: URL request.
    - returns: Observable sequence of response JSON.
    */
    public func rx_JSON(request: NSURLRequest) -> Observable<AnyObject!> {
        return rx_data(request).map { (data) -> AnyObject! in
            return try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: [])
        }
    }

    /**
    Observable sequence of response JSON for GET request with `URL`.
    
    Performing of request starts after observer is subscribed and not after invoking this method.
    
    **URL requests will be performed per subscribed observer.**
    
    Any error during fetching of the response will cause observed sequence to terminate with error.
    
    If response is not HTTP response with status code in the range of `200 ..< 300`, sequence
    will terminate with `(RxCocoaErrorDomain, RxCocoaError.NetworkError)`.
    
    If there is an error during JSON deserialization observable sequence will fail with that error.
    
    - parameter URL: URL of `NSURLRequest` request.
    - returns: Observable sequence of response JSON.
    */
    public func rx_JSON(URL: NSURL) -> Observable<AnyObject!> {
        return rx_JSON(NSURLRequest(URL: URL))
    }
}
