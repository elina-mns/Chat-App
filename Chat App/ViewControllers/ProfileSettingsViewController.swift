//
//  ProfileSettingsVCViewController.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-06.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    enum ProfileSection: Int, CaseIterable {
        case profilePicture,
             logOut
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch ProfileSection.allCases[indexPath.row] {
        case .profilePicture:
            cell.textLabel?.text = "Profile picture or info"
            cell.textLabel?.textAlignment = .center
        case .logOut:
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textAlignment = .center
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch ProfileSection.allCases[indexPath.row] {
        case .profilePicture:
            print("tap on profile picture")
        case .logOut:
            logOut()
        }
    }
    
    private func logOut() {
        showAlert(title: "Log out", message: "Are you sure you would like to log out?") {
            //Facebook log out
            FBSDKLoginKit.LoginManager().logOut()
            //Google log out
            GIDSignIn.sharedInstance()?.signOut()
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginVC()
                let navigation = UINavigationController(rootViewController: vc)
                navigation.modalPresentationStyle = .fullScreen
                self.present(navigation, animated: true)
            }
            catch {
                print("Failed to log out")
            }
        }
    }
}
