import os.log
import CoreData

final class ValidatorProvider {
    /// Storage for a shared persistent container instance.
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Courses")
        
        container.loadPersistentStores { (_, error) in
            guard error == nil else {
                fatalError("[ValidatorProvider] - Unresolved error while loading stores: \(error!)")
            }
        }
        
        return container
    }()
    
    /// The URL that this class will use to communicate with the server to validate an existing session.
    private let validateURL = "http://192.168.1.127:8080/api/validate/"
    
    /// Returns a new managed object context. Currently, this method simply
    /// returns a new background context for `persistentContainer`, but in the
    /// future we might need to customise the background context.
    /// - Returns: A new background context.
    private func newTaskContext() -> NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
    }
    
    /// Checks if there is an already existing user in the database
    /// and validates that user's session with the server.
    /// - Returns: A fully configured `UserSession` object
    ///     if the session is valid; otherwise an empty object.
    func validateExistingSession() -> UserSession {
        // Create an environment session for the user.
        let userSession = UserSession()
        let context = self.newTaskContext()
        
        // Fetch all the sessions present in the persistent store.
        let fetchRequest = NSFetchRequest<SessionMO>(entityName: "Session")
        
        // Execute and store the results of the fetch request.
        let fetchResults: [SessionMO]
        do {
            fetchResults = try context.fetch(fetchRequest)
        }
        catch {
            fatalError("[ValidationProvider] - Could not fetch sessions.\nError:\(error)")
        }
        
        // Make sure that only one session was fetched.
        if fetchResults.count == 1 {
            let session = fetchResults[0]
            
            os_log(.info, log: .default, "[ValidatorProvider] - Found a single session.")
            
            // Validate the session with the server.
            // Create a request body.
            let requestBody = ValidateSession(
                username: session.user!.username!,
                sessionID: session.sessionID!,
                sessionExpiryDate: session.sessionExpiryDate!
            )
            
            // Encode the body.
            let encodedBody: Data
            do {
                encodedBody = try JSONEncoder().encode(requestBody)
            }
            catch {
                fatalError("[ValidatorProvider] - Could not encode request body.\nError:\(error)")
            }
            
            // Create a URL to the server.
            guard let url = URL(string: validateURL) else {
                fatalError("[ValidatorProvider] - Could not contruct a valid URL.")
            }
            // Create a `URLRequest` object from the URL.
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = encodedBody
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response, _) = syncDataTaskWithURLRequest(urlRequest)
            
            switch response.statusCode {
            case 200:
                // Decode the response as `ValidateSessionResponse` object.
                let response = decodeJSON(ValidateSessionResponse.self, data: data)
                
                userSession.firstName = session.user!.firstName!
                userSession.lastName = session.user!.lastName!
                userSession.email = session.user!.email!
                userSession.lastLogin = session.user!.lastLogin!
                userSession.sessionID = session.sessionID!
                userSession.sessionExpiryDate = dateFromString(response.serialisedSessionExpiryDate)
                
                self.updateSessionExpiryDate(current: session, response: response)
            case 401:
                break
            default:
                fatalError("[ValidatorProvider] - Unexpected response code: \(response.statusCode)")
            }
        }
        else if fetchResults.count == 0 {
            os_log(.info, log: .default, "[ValidatorProvider] - Could not find any sessions.")
        }
        else {
            fatalError("[ValidatorProvider] - Found \(fetchResults.count) sessions instead of one.")
        }
        
        return userSession
    }
    
    /// Updates the session expiry date only if the current session expiry date has changed.
    /// - Parameters:
    ///     - current: The managed session object that has to be updated.
    ///     - response: The response from the server.
    private func updateSessionExpiryDate(current: SessionMO, response: ValidateSessionResponse) {
        let context = self.newTaskContext()
        
        if current.sessionExpiryDate! != response.serialisedSessionExpiryDate {
            current.sessionExpiryDate = response.serialisedSessionExpiryDate
            
            do {
                try context.save()
            }
            catch {
                fatalError("[ValidatorProvider] - Could not update session expiry date.")
            }
            
            os_log(.info, log: .default, "[ValidatorProvider] - Updated session expiry date.")
        }
    }
}
