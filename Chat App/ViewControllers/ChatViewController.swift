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
import JGProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var isLoggedIn: Bool?
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    let noChatsFound: UILabel = {
        let label = UILabel()
        label.text = "No chats found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    let activityIndicator = JGProgressHUD(style: .light)
    
    let APIkey = "2ETzPkxoPDUwIIgs1Vt465sBAvQeuiZK"   //API key for gifs
    
    struct Message: Hashable {
        var message: String
        var nickname: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noChatsFound)
        tableView.delegate = self
        tableView.dataSource = self
        fetchChats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapComposeButton() {
        let vc = NewChatVC()
        let navvc = UINavigationController(rootViewController: vc)
        present(navvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = SelectedChatVC()
        vc.title = "Ivan Dorn"
        navigationController?.pushViewController(vc, animated: true)
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
    
    func fetchChats() {
        tableView.isHidden = false
    }
}

