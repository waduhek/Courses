import Foundation
import Combine

/// Function to decode a `Data` object to a generic type `T` where
/// `T` is a `Decodable`.
/// - Parameter data: The data that has to be decoded.
func decodeJSON<T: Decodable>(data: Data) -> T {
    let decoder = JSONDecoder()
    
    do {
        return try decoder.decode(T.self, from: data)
    }
    catch {
        fatalError("Could not decode data as \(T.self).")
    }
}

/// A utility function that performs a data task using `URLSession.shared`.
/// - Parameters:
///     - _: A `URLRequest` object that has the required configuration.
///     - completionHandler: The task to perform after the data task is completed.
func dataTaskWithURLRequest(_ urlRequest: URLRequest,
                            completionHandler: @escaping (Data, HTTPURLResponse, Error?) -> Void) {
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        guard error == nil,
            let data = data,
            let response = response as? HTTPURLResponse
            else {
                return
        }
        
        completionHandler(data, response, error)
    }.resume()
}

/// A class that manages all of the user's information sent and received from the server.
final class UserSession: ObservableObject {
    // User information.
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var lastLogin: String = ""
    // Session information.
    @Published var sessionID: String = ""
    @Published var sessionExpiryDate: String = ""
    @Published var status: UserSession.HTTPStatus = .unknown
    
    /// Function for logging in the user.
    /// - Parameter credentials: A `UserCredentials` object. This function needs just `username` and
    ///     password field to be entered.
    func loginUser(credentials: UserCredentials) {
        let encodedData: Data
        
        // Try to encode the data to a `Data` type.
        do {
            encodedData = try JSONEncoder().encode(credentials)
        }
        catch {
            fatalError("Could not encode user credentials.")
        }
        
        // Creating a URL to the server.
        let url = URL(string: "http://192.168.1.127:8080/api/login/")
        
        // Creating a request to the URL of the server and setting some parameters.
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encodedData
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Start an asynchronous request to the server to login the user.
        dataTaskWithURLRequest(urlRequest) { (data, response, error) in
            switch response.statusCode {
            // Login was successful.
            case 200:
                // Decode the data sent from the server
                let userData: UserData = decodeJSON(data: data)
                
                DispatchQueue.main.async {
                    // Set all the relevant information.
                    self.firstName = userData.firstName
                    self.lastName = userData.lastName
                    self.email = userData.email
                    self.lastLogin = userData.lastLogin
                    self.sessionID = userData.sessionID
                    self.sessionExpiryDate = userData.sessionExpiryDate
                    self.status = .authorised
                }
            
            // Invalid login credentials.
            case 401:
                DispatchQueue.main.async {
                    self.status = .unauthorised
                }
                
            case 403:
                DispatchQueue.main.async {
                    self.status = .forbidden
                }
                
            default:
                DispatchQueue.main.async {
                    self.status = .error
                }
            }
        }
    }
    
    /// Function to logout the user.
    func logoutUser() {
        // Contruct the data that will be sent to the server.
        let requestData: UserLogout = UserLogout(sessionID: self.sessionID)
        
        // Storage for the result of encoding.
        let encodedData: Data
        
        // Try to encode the data for sending as JSON.
        // Raise a `fatalError` if encoding fails.
        do {
            encodedData = try JSONEncoder().encode(requestData)
        }
        catch {
            fatalError("Could not encode session ID.")
        }
        
        // URL for the logour request.
        let url = URL(string: "http://192.168.1.127:8080/api/logout/")
        
        // Constructing the `URLRequest` object and setting necessary parameters.
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encodedData
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send the request to the server asynchronously.
        dataTaskWithURLRequest(urlRequest) { (data, response, error) in
            // Response from the server.
            let responseData: UserLogoutResponse = decodeJSON(data: data)
            
            // Check for the status code received from the server.
            switch response.statusCode {
            // User was successfully logged out. Delete all the stored data.
            case 200:
                DispatchQueue.main.async {
                    self.firstName = ""
                    self.lastName = ""
                    self.email = ""
                    self.lastLogin = ""
                    self.sessionID = ""
                    self.sessionExpiryDate = ""
                    self.status = .authorised
                }
                
            // Unexpected status code. Raise a `fatalError`.
            default:
                DispatchQueue.main.async {
                    self.status = .error
                }
                
                fatalError(responseData.body)
            }
        }
    }
    
    /// Function to signup a new user.
    /// - Parameter userCredentials: A `UserCredentials` object. This function expects all the fields to be set.
    func signupUser(userCredentials: UserSignup) {
        let encodedData: Data
        
        do {
            encodedData = try JSONEncoder().encode(userCredentials)
        }
        catch {
            fatalError("Could not encode data.")
        }
        
        // Request URL.
        let url = URL(string: "http://192.168.1.127:8080/api/signup/")
        
        // Construct a `URLRequest` object for the URL and configure some parameters.
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encodedData
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Start an asynchronous data task for this `URLRequest` object.
        dataTaskWithURLRequest(urlRequest) { (data, response, error) in
            switch response.statusCode {
            // Signup was successful.
            case 200:
                // Decode the data sent from the server
                let userData: UserData = decodeJSON(data: data)
                
                DispatchQueue.main.async {
                    // Set all the relevant information.
                    self.firstName = userData.firstName
                    self.lastName = userData.lastName
                    self.email = userData.email
                    self.lastLogin = userData.lastLogin
                    self.sessionID = userData.sessionID
                    self.sessionExpiryDate = userData.sessionExpiryDate
                    self.status = .authorised
                }
                
            // The username requested is taken.
            case 599:
                DispatchQueue.main.async {
                    self.status = .usernameTaken
                }
                
            // Unexpected error occured.
            default:
                DispatchQueue.main.async {
                    self.status = .error
                }
            }
        }
    }
    
    enum HTTPStatus {
        // General status.
        case authorised, unauthorised
        // Sign up related status.
        case usernameTaken
        // Error status.
        case forbidden
        case unknown
        case error
    }
}
