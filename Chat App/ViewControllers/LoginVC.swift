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

class LoginVC: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var loginWithGoogle: GIDSignInButton!
    @IBOutlet weak var loginWithFB: FBLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLogginIn = false
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        loginWithFB.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
          // Automatically sign in the user
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AccessToken.current !=  nil {
            self.performSegue(withIdentifier: "didLogin", sender: self)
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        loginWithGoogle.isEnabled = !loggingIn
        loginWithFB.isEnabled = !loggingIn
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
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
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
}
