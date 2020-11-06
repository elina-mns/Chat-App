//
//  ProfileSettingsVCViewController.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-06.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlert(title: "Log out", message: "Are you sure you would like to log out?") {
            FBSDKLoginKit.LoginManager().logOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginVC()
                let navigation = UINavigationController(rootViewController: vc)
                navigation.modalPresentationStyle = .fullScreen
                present(navigation, animated: true)
            }
            catch {
                print("Failed to log out")
            }
        }
        
    }
}
