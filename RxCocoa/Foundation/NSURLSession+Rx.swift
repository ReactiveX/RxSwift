//
//  NSURLSession+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

/**
RxCocoa URL errors.
*/
public enum RxCocoaURLError
    : Swift.Error
    , CustomDebugStringConvertible {
    /**
    Unknown error occurred.
    */
    case unknown
    /**
    Response is not NSHTTPURLResponse
    */
    case nonHTTPResponse(response: URLResponse)
    /**
    Response is not successful. (not in `200 ..< 300` range)
    */
    case httpRequestFailed(response: HTTPURLResponse, data: Data?)
    /**
    Deserialization error.
    */
    case deserializationError(error: Swift.Error)
}

public extension RxCocoaURLError {
    /**
    A textual representation of `self`, suitable for debugging.
    */
    public var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error has occurred."
        case let .nonHTTPResponse(response):
            return "Response is not NSHTTPURLResponse `\(response)`."
        case let .httpRequestFailed(response, _):
            return "HTTP request failed with `\(response.statusCode)`."
        case let .deserializationError(error):
            return "Error during deserialization of the response: \(error)"
        }
    }
}

func escapeTerminalString(_ value: String) -> String {
    return value.replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil)
}

func convertURLRequestToCurlCommand(_ request: URLRequest) -> String {
    let method = request.httpMethod ?? "GET"
    var returnValue = "curl -X \(method) "

    if let httpBody = request.httpBody, request.httpMethod == "POST" {
        let maybeBody = String(data: httpBody, encoding: String.Encoding.utf8)
        if let body = maybeBody {
            returnValue += "-d \"\(escapeTerminalString(body))\" "
        }
    }

    for (key, value) in request.allHTTPHeaderFields ?? [:] {
        let escapedKey = escapeTerminalString(key as String)
        let escapedValue = escapeTerminalString(value as String)
        returnValue += "\n    -H \"\(escapedKey): \(escapedValue)\" "
    }

    let URLString = request.url?.absoluteString ?? "<unknown url>"

    returnValue += "\n\"\(escapeTerminalString(URLString))\""

    returnValue += " -i -v"

    return returnValue
}

func convertResponseToString(_ data: Data!, _ response: URLResponse!, _ error: NSError!, _ interval: TimeInterval) -> String {
    let ms = Int(interval * 1000)

    if let response = response as? HTTPURLResponse {
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

extension Reactive where Base: URLSession {
    /**
    Observable sequence of responses for URL request.
    
    Performing of request starts after observer is subscribed and not after invoking this method.
    
    **URL requests will be performed per subscribed observer.**
    
    Any error during fetching of the response will cause observed sequence to terminate with error.
    
    - parameter request: URL request.
    - returns: Observable sequence of URL responses.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func response(_ request: URLRequest) -> Observable<(Data, HTTPURLResponse)> {
        return Observable.create { observer in

            // smart compiler should be able to optimize this out
            let d: Date?

            if Logging.URLRequests(request) {
                d = Date()
            }
            else {
               d = nil
            }

            let task = self.base.dataTask(with: request) { (data, response, error) in

                if Logging.URLRequests(request) {
                    let interval = Date().timeIntervalSince(d ?? Date())
                    print(convertURLRequestToCurlCommand(request))
                    print(convertResponseToString(data, response, error as NSError!, interval))
                }
                
                guard let response = response, let data = data else {
                    observer.on(.error(error ?? RxCocoaURLError.unknown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(RxCocoaURLError.nonHTTPResponse(response: response)))
                    return
                }

                observer.on(.next(data, httpResponse))
                observer.on(.completed)
            }


            let t = task
            t.resume()

            return Disposables.create(with: task.cancel)
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
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func data(_ request: URLRequest) -> Observable<Data> {
        return response(request).map { (data, response) -> Data in
            if 200 ..< 300 ~= response.statusCode {
                return data
            }
            else {
                throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
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
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func JSON(_ request: URLRequest) -> Observable<Any> {
        return data(request).map { (data) -> Any in
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error {
                throw RxCocoaURLError.deserializationError(error: error)
            }
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
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func JSON(_ URL: Foundation.URL) -> Observable<Any> {
        return JSON(URLRequest(url: URL))
    }
}

