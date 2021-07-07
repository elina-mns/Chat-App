//
//  AppDelegate.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-04.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import GiphyUISDK
import JGProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    let activityIndicator = JGProgressHUD(style: .light)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Giphy.configure(apiKey: "2ETzPkxoPDUwIIgs1Vt465sBAvQeuiZK")
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        guard let user = user else { return }
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else { return }
        
        let chatUser = ProfileInfo(firstName: firstName, lastName: lastName, email: email, id: user.userID)
        
        activityIndicator.show(in: getCurrentViewController()?.view ?? UIView())
        DatabaseManager.shared.addUser(user: chatUser, completion: { success in
            if success {
                //check if we have an image from Google
                if user.profile.hasImage {
                    guard let url = user.profile.imageURL(withDimension: 200) else { return }
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                        guard let data = data else { return }
                        //then download the bytes from this URL
                        let fileName = chatUser.profilePicFileName
                        StorageFirebase.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {
                            result in
                            self.activityIndicator.dismiss()
                            switch result {
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                UserDefaults.standard.set(email, forKey: "email")
                                print(downloadURL)
                            case .failure(let error):
                                print(error)
                                self.getCurrentViewController()?.showAlert(title: "Error", message: error.localizedDescription, actionForOk: nil)
                            }
                        })
                    }).resume()
                }
            }
            
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Invalid google credential")
                    return
                }
                print("Successfully signed in with Google cred.")
                UserDefaults.standard.set(user.userID, forKey: "user_id")
                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "display_name")
                UserDefaults.standard.set(email, forKey: "email")
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            })
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
    
    // MARK: - Core Data stack
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func getCurrentViewController() -> UIViewController? {

        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {

            return navigationController.visibleViewController
        }

        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {

            var currentController: UIViewController! = rootController

            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {

                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    private func getNavigationController() -> UINavigationController? {

        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {

            return navigationController as? UINavigationController
        }
        return nil
    }
}
