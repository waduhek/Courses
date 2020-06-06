// This file describes the structs used for requests and replies sent to and received from the server.
import Foundation

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
    fileprivate var sessionExpireDate: String = ""
    
    // MARK: Converting the session expiry date into a `String` type for use in cookies.
    var sessionExpiryDate: String {
        // Create a `DateFormatter` instance and customise some properties.
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-mm-dd'T'H:mm:ss.SZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Create a `Date` type from received string.
        let date = dateFormatter.date(from: self.sessionExpireDate)!
        
        // Getting a current calendar.
        var calendar = Calendar.current
        // Set the calendar's timezone to UTC.
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let sessionExpiryDateComponents = calendar.dateComponents(
            [
                .hour, .minute, .second,
                .year, .month, .day
            ],
            from: date
        )
        
        // Separating individual components of the expoiry date.
        let year = String(sessionExpiryDateComponents.year!)
        var month = String(sessionExpiryDateComponents.month!)
        var day = String(sessionExpiryDateComponents.day!)
        var hour = String(sessionExpiryDateComponents.hour!)
        var minute = String(sessionExpiryDateComponents.minute!)
        var second = String(sessionExpiryDateComponents.second!)
        
        // Making sure that the month, day, hour, minute and second are 2 digits.
        if month.count == 1 {
            month.insert("0", at: month.startIndex)
        }
        
        if day.count == 1 {
            day.insert("0", at: day.startIndex)
        }
        
        if hour.count == 1 {
            hour.insert("0", at: hour.startIndex)
        }
        
        if minute.count == 1 {
            minute.insert("0", at: minute.startIndex)
        }
        
        if second.count == 1 {
            second.insert("0", at: second.startIndex)
        }
        
        // Return a formatted string.
        return "\(year)-\(month)-\(day) \(hour):\(minute):\(second)+00:00"
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
