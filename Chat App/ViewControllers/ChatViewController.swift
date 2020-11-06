//
//  ViewController.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-04.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseAuth

class ChatViewController: UIViewController {
    
    var isLoggedIn: Bool?
    
    let APIkey = "2ETzPkxoPDUwIIgs1Vt465sBAvQeuiZK"   //API key for gifs
    
    struct Message: Hashable {
        var message: String
        var nickname: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmAuth()
    }
    
    func confirmAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let navigation = UINavigationController(rootViewController: vc)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
    }
    
    func configureAuth() {
        
    }
    
    func configureDatabase() {
        
    }
    
    func sendMessage(message: Message) {
         
    }
}

