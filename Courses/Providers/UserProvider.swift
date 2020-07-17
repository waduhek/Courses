import CoreData

class UserProvider {
    /// Storage for a shared persistent container instance.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Courses")
        
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("[CourseProvider] - Unresolved error: \(error!)")
            }
        }
        
        return container
    }()
    
    /// Returns a new managed object context. Currently, this method simply
    /// returns a new background context for `persistentContainer`, but in the
    /// future we might need to customise the background context.
    /// - Returns: A new background context.
    private func newTaskContext() -> NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
    }
    
    /// Fetches the user with the given username.
    /// - Parameter username: The username of the user. It will be used as a
    ///     predicate for search.
    /// - Returns: Array of all matching users (ideally 1).
    func fetchUsers(username: String) -> [UserMO] {
        let context = self.newTaskContext()
        
        let fetchRequest: NSFetchRequest<UserMO> = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        
        let fetchResults: [UserMO]
        do {
            fetchResults = try context.fetch(fetchRequest)
        }
        catch {
            fatalError("[CourseProvider/FetchUser] - Could not fetch user: \(error)")
        }
        
        return fetchResults
    }
    
    /// Updates the user's last login date as reported by the server and checks if the session
    /// expiry date is different from the one received from the server. If the the session expiry
    /// date has been modified then, it stores the modified expiry date.
    /// - Parameters:
    ///     - user: The user's managed object whose information has to be updated.
    ///     - userData: The user data as received from the server.
    func updateUserInformationOnLogin(user: UserMO, userData: UserData) {
        let context = self.newTaskContext()
        
        user.lastLogin = userData.lastLogin
        
        // Update the session expiry date if it has changed.
        if userData.serialisedSessionExpiryDate != user.session!.sessionExpiryDate {
            user.session!.sessionExpiryDate = userData.serialisedSessionExpiryDate
        }
        
        // Save this information.
        do {
            try context.save()
        }
        catch {
            fatalError("[CourseProvider/UpdateUserOnLogin] - Could not save data.")
        }
    }
    
    /// Creates an entry for a new user.
    /// - Parameters:
    ///     - username: Username.
    ///     - userData: The decoded data received from the server.
    func createNewUser(username: String, userData: UserData) {
        let context = self.newTaskContext()
        
        // Attempt to insert this new user into the store.
        guard let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? UserMO else {
            fatalError("[CourseProvider/CreateUser] - Could not create a new user record.")
        }
        
        // Set the properties of the new user.
        newUser.username = username
        newUser.firstName = userData.firstName
        newUser.lastName = userData.lastName
        newUser.email = userData.email
        newUser.lastLogin = userData.lastLogin
        newUser.isTeacher = userData.isTeacher
        
        // Attempt to create a new session entry into the store.
        guard let newSession = NSEntityDescription.insertNewObject(forEntityName: "Session", into: context) as? SessionMO else {
            fatalError("[CourseProvider/CreateUser] - Could not create a new session.")
        }
        
        // Set session related information.
        newSession.sessionID = userData.sessionID
        newSession.sessionExpiryDate = userData.serialisedSessionExpiryDate
        
        // Enter the relationship information.
        newUser.session = newSession
        newSession.user = newUser
        
        // Try to save all of the information.
        do {
            try context.save()
        }
        catch {
            fatalError("[CourseProvider/CreateUser] - Could not save information.")
        }
    }
}
