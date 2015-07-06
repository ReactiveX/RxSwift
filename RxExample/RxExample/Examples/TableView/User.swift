
import Foundation

struct User: Equatable, CustomStringConvertible {
    
    var firstName: String
    var lastName: String
    var imageURL: String
    
    init(firstName: String, lastName: String, imageURL: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
    }
    
    var description: String {
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