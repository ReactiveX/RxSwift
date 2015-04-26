//
//  GitHubAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class GitHubAPI {
    let dataScheduler: ImmediateScheduler
    let URLSession: NSURLSession
    
    init(dataScheduler: ImmediateScheduler, URLSession: NSURLSession) {
        self.dataScheduler = dataScheduler
        self.URLSession = URLSession
    }
    
    func usernameAvailable(username: String) -> Observable<Bool> {
        // this is ofc just mock, but good enough
        
        let URL = NSURL(string: "https://github.com/\(URLEscape(username))")!
        let request = NSURLRequest(URL: URL)
        return self.URLSession.rx_request(request) >- map { (maybeData, maybeResponse) in
            if let response = maybeResponse as? NSHTTPURLResponse {
                return response.statusCode == 404
            }
            else {
                return false
            }
        } >- catch { result in
            return returnElement(false)
        }
    }
    
    func signup(username: String, password: String) -> Observable<Void> {
        // this is also just a mock
        return returnElement(()) >- throttle(0.700, MainScheduler.sharedInstance)
    }
}