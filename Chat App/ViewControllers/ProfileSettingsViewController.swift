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
        tableView.register(UINib(nibName: "LogOutTableViewCell", bundle: nil), forCellReuseIdentifier: "LogOutTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentMode = .center
        tableView.tableHeaderView = createTableHeader()
        
        let background = UIImageView();
        background.image = UIImage(named: "1");
        background.contentMode = .scaleToFill
        self.tableView.backgroundView = background
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ProfileSection.allCases[indexPath.row] {
        case .profilePicture:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = UserDefaults.standard.value(forKey: "display_name") as? String
            cell.textLabel?.font = .boldSystemFont(ofSize: 20)
            //cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        case .logOut:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LogOutTableViewCell",
                for: indexPath) as! LogOutTableViewCell
            cell.delegate = self
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch ProfileSection.allCases[indexPath.row] {
        case .profilePicture:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
        case .logOut:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LogOutTableViewCell",
                for: indexPath) as! LogOutTableViewCell
            cell.delegate = self
        }
    }
    
    func createTableHeader() -> UIView? {
        guard let profilePictureURLString = UserDefaults.standard.value(forKey: "profile_picture_url") as? String,
              let profilePictureURL = URL(string: profilePictureURLString) else {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.bounds.width,
                                              height: 300))
        
        view.backgroundColor = .clear
        
        let imageView = UIImageView(frame: CGRect(x: (view.bounds.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width/2
        view.addSubview(imageView)
    
        
        downloadImage(imageView: imageView, url: profilePictureURL)        
        return view
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, URLResponse, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }

    
    private func logOut() {
        showAlert(title: "Log out", message: "Are you sure you would like to log out?") {
            //Facebook log out
            FBSDKLoginKit.LoginManager().logOut()
            //Google log out
            GIDSignIn.sharedInstance()?.signOut()
            do {
                try FirebaseAuth.Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            }
            catch {
                print("Failed to log out")
            }
        }
    }
}

extension ProfileSettingsViewController: LogOutTableViewCellDelegate {
    func logOutButtonPressed() {
        logOut()
    }
}
