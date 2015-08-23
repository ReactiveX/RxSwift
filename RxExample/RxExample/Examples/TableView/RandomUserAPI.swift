//
//  RandomUserAPI.swift
//  RxExample
//
//  Created by carlos on 28/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

class RandomUserAPI {
    
    static let sharedAPI = RandomUserAPI()
    
    private init() {}
    
    func getExampleUserResultSet() -> Observable<[User]> {
        let url = NSURL(string: "http://api.randomuser.me/?results=20")!
        return NSURLSession.sharedSession().rx_JSON(url)
            .observeSingleOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { json in
                guard let json = json as? [String: AnyObject] else {
                    throw exampleError("Casting to dictionary failed")
                }
                
                return try self.parseJSON(json)
            }
            .observeSingleOn(Dependencies.sharedDependencies.mainScheduler)
    }
    
    private func parseJSON(json: [String: AnyObject]) throws -> [User] {
        guard let results = json["results"] as? [[String: AnyObject]] else {
            throw exampleError("Can't find results")
        }
        
        let users = results.map { $0["user"] as? [String: AnyObject] }.filter { $0 != nil }
        
        let userParsingError = exampleError("Can't parse user")
        
        let searchResults: [RxResult<User>] = users.map { user in
            let name = user?["name"] as? [String: String]
            let pictures = user?["picture"] as? [String: String]
            
            guard let firstName = name?["first"], let lastName = name?["last"], let imageURL = pictures?["medium"] else {
                return failure(userParsingError)
            }
            
            let returnUser = User(firstName: firstName.capitalizedString,
                lastName: lastName.capitalizedString,
                imageURL: imageURL)
            return success(returnUser)
        }
        
        let values = (searchResults.filter { $0.isSuccess }).map { $0.get() }
        return values
    }
}