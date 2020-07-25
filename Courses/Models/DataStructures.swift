// This file describes the structs used for requests and replies sent to and received from the server.
import Foundation
import CoreData
import SwiftUI

// MARK: - Login related structs.
/// Represents the information sent to the server when a user requests a log in or when the user wants to sign up.
struct UserCredentials: Encodable {
    var username: String
    var password: String
}

/// Stores the information the server sends back when the user successfully logs in.
struct UserData: Decodable {
    // MARK: User information.
    var firstName: String
    var lastName: String
    var email: String
    var lastLogin: String
    // MARK: Session information.
    var sessionID: String
    // Received session expiry date in RFC 3339 format.
    // This is received from the server.
    var serialisedSessionExpiryDate: String
    var isTeacher: Bool
    
    // Converting the session expiry date into a `Date` type.
    lazy var sessionExpiryDate: Date = dateFromString(self.serialisedSessionExpiryDate)
    
    enum CodingKeys: String, CodingKey {
        case firstName, lastName, email, lastLogin, sessionID, isTeacher
        
        case serialisedSessionExpiryDate = "sessionExpireDate"
    }
}

// MARK: - Logout related structs.
/// Used when the user wants to log out.
struct UserLogout: Encodable {
    var sessionID: String
}

/// This struct represents the response sent by the server after a logout request is processed.
struct UserLogoutResponse: Decodable {
    var body: String
}

// MARK: - Signup related structs.
/// Represents the data sent to the server when the user wants to sign up.
struct UserSignup: Encodable {
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var password: String
    var confirmPassword: String
    var isTeacher: Bool
}

// MARK: - Validation related structs.
/// Represents the data sent to the server for validation of session.
struct ValidateSession: Encodable {
    var username: String
    var sessionID: String
    var sessionExpiryDate: String
    
    enum CodingKeys: String, CodingKey {
        case username, sessionID
        case sessionExpiryDate = "sessionExpireDate"
    }
}

/// Represents the data received from the server after a validation request.
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

// MARK: - Course related structs.

/// Stores minimal information of a course. This is for use in
/// non detail views.
struct CourseSummary: Decodable, Identifiable {
    var id: UInt
    var name: String
    var imageURL: String
    
    var image: Image {
        get {
            loadImage(fromURL: self.imageURL)
        }
    }
}

/// Stores detail information of a course.
struct Course: Decodable, Identifiable {
    var id: UInt
    var name: String
    var description: String
    var teachers: [String]
    var videos: [CourseVideo]
    private var imageURL: String
    
    var image: Image {
        get {
            loadImage(fromURL: self.imageURL)
        }
    }
    
    init() {
        self.id = 0
        self.name = ""
        self.description = ""
        self.teachers = []
        self.videos = []
        // Set the image URL to the default image URL.
        self.imageURL = "http://192.168.1.127:8080/short/f38e60deaac74a7/"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, teachers, videos
        case imageURL = "image"
    }
}

struct CourseVideo: Decodable, Identifiable {
    var id: UInt
    var title: String
    var description: String
    var url: String
    var dateUploadedString: String
    lazy var dateUploaded: Date = dateFromString(self.dateUploadedString)
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, url
        case dateUploadedString = "dateUploaded"
    }
}
