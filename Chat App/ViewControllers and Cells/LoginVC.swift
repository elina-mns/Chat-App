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
    
    //MARK: Properties

    @IBOutlet weak var loginWithGoogle: GIDSignInButton!
    @IBOutlet weak var loginWithFB: FBLoginButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goToConvosButton: UIBarButtonItem!
    
    let activityIndicator = JGProgressHUD(style: .light)
    var isLogginIn = false
    var observer: NSObjectProtocol?
    
    //MARK: Actions
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func didTapGoToConvos(_ sender: Any) {
        showListOfConversationsVC()
    }
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
        guard self != nil else { return }
            self?.showListOfConversationsVC()
        })
        loginWithFB.delegate = self
        loginWithFB.permissions = ["public_profile ", "email"]
        loginWithFB.sizeThatFits(CGSize(width: 50, height: 50))
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        navigationController?.navigationBar.tintColor = .purple
        titleLabel.text = ""
        var characterIndex = 0
        let titleText = "⚡️Chat App⚡️"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(characterIndex), repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            characterIndex += 1
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.title = "⚡️Chat App⚡️"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AccessToken.current != nil {
            showListOfConversationsVC()
        }
        goToConvosButton.isEnabled = true
        goToConvosButton.tintColor = .purple
    }
    
    //MARK: Login
    
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
        
        facebookRequest.start(completion: { _, result, error in
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
    
    //MARK: Show List of Conversations
    
    @objc func showListOfConversationsVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "ListOfMessagesViewController") as! ListOfMessagesViewController
        self.navigationController?.pushViewController(resultViewController, animated: false)
    }
}
