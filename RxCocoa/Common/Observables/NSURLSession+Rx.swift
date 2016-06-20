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
    : ErrorProtocol
    , CustomDebugStringConvertible {
    /**
    Unknown error occurred.
    */
    case Unknown
    /**
    Response is not NSHTTPURLResponse
    */
    case NonHTTPResponse(response: URLResponse)
    /**
    Response is not successful. (not in `200 ..< 300` range)
    */
    case HTTPRequestFailed(response: HTTPURLResponse, data: NSData?)
    /**
    Deserialization error.
    */
    case DeserializationError(error: ErrorProtocol)
}

public extension RxCocoaURLError {
    /**
    A textual representation of `self`, suitable for debugging.
    */
    public var debugDescription: String {
        switch self {
        case .Unknown:
            return "Unknown error has occurred."
        case let .NonHTTPResponse(response):
            return "Response is not NSHTTPURLResponse `\(response)`."
        case let .HTTPRequestFailed(response, _):
            return "HTTP request failed with `\(response.statusCode)`."
        case let .DeserializationError(error):
            return "Error during deserialization of the response: \(error)"
        }
    }
}

func escapeTerminalString(value: String) -> String {
    return value.replacingOccurrences(of: "\"", with: "\\\"")
}

func convertURLRequestToCurlCommand(request: URLRequest) -> String {
    let method = request.httpMethod ?? "GET"
    var returnValue = "curl -X \(method) "

    if  request.httpMethod == "POST" && request.httpBody != nil {
        let maybeBody = String(data: request.httpBody!, encoding: String.Encoding.utf8)
        if let body = maybeBody {
            returnValue += "-d \"\(escapeTerminalString(value: body))\" "
        }
    }

    for (key, value) in request.allHTTPHeaderFields ?? [:] {
        let escapedKey = escapeTerminalString(value: (key as String) ?? "")
        let escapedValue = escapeTerminalString(value: (value as String) ?? "")
        returnValue += "\n    -H \"\(escapedKey): \(escapedValue)\" "
    }

    let URLString = request.url?.absoluteString ?? "<unknown url>"

    returnValue += "\n\"\(escapeTerminalString(value: URLString))\""

    returnValue += " -i -v"

    return returnValue
}

func convertResponseToString(data: Data!, _ response: URLResponse!, _ error: NSError!, _ interval: TimeInterval) -> String {
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

extension URLSession {
    /**
    Observable sequence of responses for URL request.
    
    Performing of request starts after observer is subscribed and not after invoking this method.
    
    **URL requests will be performed per subscribed observer.**
    
    Any error during fetching of the response will cause observed sequence to terminate with error.
    
    - parameter request: URL request.
    - returns: Observable sequence of URL responses.
    */
    @warn_unused_result(message: "http://git.io/rxs.uo")
    public func rx_response(request: URLRequest) -> Observable<(Data, HTTPURLResponse)> {
        return Observable.create { observer in

            // smart compiler should be able to optimize this out
            var d: Date?

            if Logging.URLRequests(request) {
                d = Date()
            }

            let task = self.dataTask(with: request) { (data, response, error) in

                if Logging.URLRequests(request) {
                    let interval = Date().timeIntervalSince(d ?? Date())
                    print(convertURLRequestToCurlCommand(request: request))
                    print(convertResponseToString(data: data, response, error, interval))
                }
                
                guard let response = response, data = data else {
                    observer.on(event: .Error(error ?? RxCocoaURLError.Unknown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(event: .Error(RxCocoaURLError.NonHTTPResponse(response: response)))
                    return
                }

                observer.on(event: .Next(data, httpResponse))
                observer.on(event: .Completed)
            }


            let t = task
            t.resume()

            return AnonymousDisposable(task.cancel)
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
    @warn_unused_result(message: "http://git.io/rxs.uo")
    public func rx_data(request: URLRequest) -> Observable<Data> {
        return rx_response(request: request).map { (data, response) -> Data in
            if 200 ..< 300 ~= response.statusCode {
                return data
            }
            else {
                throw RxCocoaURLError.HTTPRequestFailed(response: response, data: data)
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
    @warn_unused_result(message: "http://git.io/rxs.uo")
    public func rx_JSON(request: URLRequest) -> Observable<AnyObject> {
        return rx_data(request: request).map { (data) -> AnyObject in
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error {
                throw RxCocoaURLError.DeserializationError(error: error)
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
    @warn_unused_result(message: "http://git.io/rxs.uo")
    public func rx_JSON(url: URL) -> Observable<AnyObject> {
        return rx_JSON(request: URLRequest(url: url))
    }
}
