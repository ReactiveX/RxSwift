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
                    observer.on(.Error(error ?? UnknownError))
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

    public func rx_data(request: NSURLRequest) -> Observable<NSData> {
        return rx_response(request).map { (data, response) -> NSData in
            if let response = response as? NSHTTPURLResponse {
                if 200 ..< 300 ~= response.statusCode {
                    return data ?? NSData()
                }
                else {
                    throw rxError(.NetworkError, message: "Server returned failure", userInfo: [RxCocoaErrorHTTPResponseKey: response])
                }
            }
            else {
                rxFatalError("response = nil")

                throw UnknownError
            }
        }
    }

    public func rx_JSON(request: NSURLRequest) -> Observable<AnyObject!> {
        return rx_data(request).map { (data) -> AnyObject! in
            return try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: [])
        }
    }

    public func rx_JSON(URL: NSURL) -> Observable<AnyObject!> {
        return rx_JSON(NSURLRequest(URL: URL))
    }
}
