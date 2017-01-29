//
//  RandomUserAPI.swift
//  RxExample
//
//  Created by carlos on 28/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif

import struct Foundation.URL
import class Foundation.URLSession

class RandomUserAPI {
    
    static let sharedAPI = RandomUserAPI()
    
    private init() {}
    
    func getExampleUserResultSet() -> Observable<[User]> {
        let url = URL(string: "http://api.randomuser.me/?results=20")!
        return URLSession.shared.rx.json(url: url)
            .map { json in
                guard let json = json as? [String: AnyObject] else {
                    throw exampleError("Casting to dictionary failed")
                }
                
                return try self.parseJSON(json)
            }
    }
    
    private func parseJSON(_ json: [String: AnyObject]) throws -> [User] {
        guard let results = json["results"] as? [[String: AnyObject]] else {
            throw exampleError("Can't find results")
        }

        let userParsingError = exampleError("Can't parse user")
       
        let searchResults: [User] = try results.map { user in
            let name = user["name"] as? [String: String]
            let pictures = user["picture"] as? [String: String]
            
            guard let firstName = name?["first"], let lastName = name?["last"], let imageURL = pictures?["medium"] else {
                throw userParsingError
            }
            
            let returnUser = User(
                firstName: firstName.capitalized,
                lastName: lastName.capitalized,
                imageURL: imageURL
            )
            return returnUser
        }
        
        return searchResults
    }
}
