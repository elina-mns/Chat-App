//
//  LoginVC.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-04.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import JGProgressHUD

class LoginVC: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var loginWithGoogle: GIDSignInButton!
    @IBOutlet weak var loginWithFB: FBLoginButton!
    let activityIndicator = JGProgressHUD(style: .light)
    
    var isLogginIn = false
    var observer: NSObjectProtocol?
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
        guard self != nil else { return }
            self?.performSegue(withIdentifier: "showChat", sender: self)
        })
        loginWithFB.delegate = self
        loginWithFB.permissions = ["public_profile ", "email"]
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AccessToken.current !=  nil {
            self.performSegue(withIdentifier: "showChat", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChat" {
            segue.destination.modalPresentationStyle = .fullScreen
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        loginWithGoogle.isEnabled = !loggingIn
        loginWithFB.isEnabled = !loggingIn
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        activityIndicator.show(in: view)
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":
                                                                        "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            print(result)
          
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureURL = data["url"] as? String,
                  let userId = result["id"] as? String else {
                print("Failed to get email and name from Facebook")
                return
            }
            
            let chatUser = ProfileInfo(firstName: firstName, lastName: lastName, email: email, id: userId)
            
            DatabaseManager.shared.addUser(user: chatUser, completion: { success in
                guard success, let url = URL(string: pictureURL) else {
                    return
                }
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
                            print(downloadURL)
                        case .failure(let error):
                            self.showAlert(title: "Error", message: error.localizedDescription, actionForOk: nil)
                            print(error)
                        }
                    })
                }).resume()
            })
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                guard authResult != nil, error == nil else {
                    print(error?.localizedDescription ?? "Invalid facebook cred")
                    return
                }
                print("Successfully signed in with facebook cred.")
                UserDefaults.standard.set(userId, forKey: "user_id")
                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "display_name")
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            }
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
}
