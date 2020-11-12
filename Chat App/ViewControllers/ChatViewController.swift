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
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    var messages = [Message]()
    var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(senderId: email,
               displayName: "Jopa",
               photoURL: "")
    }

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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noChatsFound)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    func confirmAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let navigation = UINavigationController(rootViewController: vc)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
    }
    
    func currentSender() -> SenderType {
        if let sender = sender {
            return sender
        }
        fatalError("Email should be cached")
        return Sender(senderId: "123", displayName: "", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let messageId = putMessageId(),
            let sender = self.sender else {
            return
        }
        //Send a message
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        DatabaseManager.shared.sendMessage(message: message) { success in
            if success {
                print("message was sent")
            }
            else {
                print("failed to send")
            }
        }
        
    }
    
    func putMessageId() -> String? {
        guard let userEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        let dateString = Self.dateFormatter.string(from: Date())
        let identifier = "\(userEmail)_\(dateString)"
        print("created a message ID: \(identifier)")
        return identifier
    }
    
    func configureAuth() {
        
    }
    
    func configureDatabase() {
        
    }
}

