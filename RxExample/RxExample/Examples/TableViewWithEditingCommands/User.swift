//
//  User.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct User: Equatable, CustomDebugStringConvertible {
    
    var firstName: String
    var lastName: String
    var imageURL: String
    
    init(firstName: String, lastName: String, imageURL: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
    }
}

extension User {
    var debugDescription: String {
        return firstName + " " + lastName
    }
}

func ==(lhs: User, rhs:User) -> Bool {
    return lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.imageURL == rhs.imageURL
}