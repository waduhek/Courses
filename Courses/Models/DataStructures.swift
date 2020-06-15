// This file describes the structs used for requests and replies sent to and received from the server.
import os.log
import Foundation
import CoreData
import UIKit.UIApplication

// MARK:- Login related structs.
/// This struct represents the information sent to the server when a user requests a log in or when the user wants to sign up.
struct UserCredentials: Encodable {
    var username: String
    var password: String
}

/// This struct stores the represents the information the server sends back when the user successfully logs in.
struct UserData: Decodable {
    // MARK: User information.
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var lastLogin: String = ""
    // MARK: Session information.
    var sessionID: String = ""
    // Received session expiry date in RFC 3339 format.
    // This is received from the server.
    var serialisedSessionExpiryDate: String = ""
    
    // MARK: Converting the session expiry date into a `Date` type.
    lazy var sessionExpiryDate: Date = dateFromString(self.serialisedSessionExpiryDate)
    
    enum CodingKeys: String, CodingKey {
        case firstName, lastName, email, lastLogin, sessionID
        
        case serialisedSessionExpiryDate = "sessionExpireDate"
    }
}

// MARK:- Logout related structs.
/// This struct is used when the user wants to log out.
struct UserLogout: Encodable {
    var sessionID: String
}

/// This struct represents the response sent by the server after a logout request is processed.
struct UserLogoutResponse: Decodable {
    var body: String
}

// MARK:- Signup related structs.
/// This struct represents the data sent to the server when the user wants to sign up.
struct UserSignup: Encodable {
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var password: String
    var confirmPassword: String
}

// MARK:- Validation related structs.
/// This struct represents the data sent to the server for validation of session.
struct ValidateSession: Encodable {
    var username: String
    var sessionID: String
    var sessionExpiryDate: String
    
    enum CodingKeys: String, CodingKey {
        case username, sessionID
        case sessionExpiryDate = "sessionExpireDate"
    }
}

/// This struct represents the data received from the server after a validation request.
struct ValidateSessionResponse: Decodable {
    var firstName: String
    var lastName: String
    var email: String
    var lastLogin: String
    var sessionID: String
    var serialisedSessionExpiryDate: String
    
    enum CodingKeys: String, CodingKey {
        case firstName, lastName, email, lastLogin, sessionID
        case serialisedSessionExpiryDate = "sessionExpireDate"
    }
}
