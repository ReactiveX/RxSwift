
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
        get {
            return firstName + " " + lastName
        }
    }
}

func ==(lhs: User, rhs:User) -> Bool {
    return lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.imageURL == rhs.imageURL
}