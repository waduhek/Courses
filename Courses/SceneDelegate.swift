import os.log
import UIKit
import CoreData
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        // Creating a new `UserSession` object.
        let userSession = UserSession()
        
        // Obtain the managed object context of the persistent store.
        guard let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("[SceneDelegate] - Could not get managed object context.")
        }
        
        // Fetching session ID from the store.
        // Create a fetch request.
        let fetchRequest: NSFetchRequest<SessionMO> = NSFetchRequest(entityName: "Session")
        
        let fetchResults: [SessionMO]
        // Fetch results from the data store.
        do {
            fetchResults = try managedObjectContext.fetch(fetchRequest)
        }
        catch {
            fatalError("[SceneDelegate] - Could not perform fetch request.")
        }
        
        // Make sure that there is just one session ID found.
        if fetchResults.count == 1 {
            let result = fetchResults[0]
            // Now, validate this session ID with the server.
            // Create the request body.
            let body = ValidateSession(
                username: result.user!.username!,
                sessionID: result.sessionID!,
                sessionExpiryDate: result.sessionExpiryDate!
            )
            
            // Encode the body
            let encodedBody: Data
            do {
                encodedBody = try JSONEncoder().encode(body)
            }
            catch {
                fatalError("[SceneDelegate] - Could not encode request body.")
            }
            
            // Create a `URLRequest` object.
            var urlRequest = URLRequest(url: URL(string: "http://192.168.1.127:8080/api/validate/")!)
            // Configure its parameters.
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = encodedBody
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response, _) = syncDataTaskWithURLRequest(urlRequest)
            
            switch response.statusCode {
            // The current session is already active.
            case 200:
                let responseBody: ValidateSessionResponse = decodeJSON(data: data)

                userSession.firstName = result.user!.firstName!
                userSession.lastName = result.user!.lastName!
                userSession.email = result.user!.email!
                userSession.lastLogin = result.user!.lastLogin!
                userSession.sessionID = result.sessionID!
                userSession.sessionExpiryDate = dateFromString(responseBody.serialisedSessionExpiryDate)

                // Check if the session expiry dates match. Update if they do not.
                if responseBody.serialisedSessionExpiryDate != result.sessionExpiryDate! {
                    result.sessionExpiryDate = responseBody.serialisedSessionExpiryDate

                    // Save the data.
                    do {
                        try managedObjectContext.save()
                    }
                    catch {
                        fatalError("[SceneDelegate] - Could not update session expiry date.")
                    }
                }
            // The current session is inactive or the session ID is incorrect.
            case 401:
                break
            default:
                fatalError("[SceneDelegate] - Unexpected status code.")
            }
        }
        else if fetchResults.count == 0 {
            os_log(.info, log: .default, "[SceneDelegate] - No session IDs were found.")
        }
        else {
            for result in fetchResults {
                print(result.sessionID!)
            }
            fatalError("[SceneDelegate] - Fetch request returned multiple rows.")
        }

        // Create the SwiftUI view that provides the window contents.
        let contentView = LoginView()
            .environmentObject(userSession)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

