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
            >- observeSingleOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            >- mapOrDie { json in
                return castOrFail(json).flatMap { (json: [String: AnyObject]) in
                    return self.parseJSON(json)
                }
            }
            >- observeSingleOn(Dependencies.sharedDependencies.mainScheduler)
    }
    
    private func parseJSON(json: [String: AnyObject]) -> RxResult<[User]> {
        let results = json["results"] as? [[String: AnyObject]]
        let users = results?.map { $0["user"] as? [String: AnyObject] }
        
        let error = NSError(domain: "UserAPI", code: 0, userInfo: nil)
        
        if let users = users {
            let searchResults: [RxResult<User>] = users.map { user in
                let name = user?["name"] as? [String: String]
                let pictures = user?["picture"] as? [String: String]
                
                if let firstName = name?["first"], let lastName = name?["last"], let imageURL = pictures?["medium"] {
                    let returnUser = User(firstName: firstName.uppercaseFirstCharacter(),
                        lastName: lastName.uppercaseFirstCharacter(),
                        imageURL: imageURL)
                    return success(returnUser)
                }
                else {
                    return failure(error)
                }
            }
            
            let values = (searchResults.filter { $0.isSuccess }).map { $0.get() }
            return success(values)
        }
        return failure(error)
    }
    
}