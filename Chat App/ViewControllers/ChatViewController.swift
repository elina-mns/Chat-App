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

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    var messages = [Message]()
    lazy var sender: Sender? = {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? String,
              let displayName = UserDefaults.standard.value(forKey: "display_name") as? String else {
              //let photoURL = UserDefaults.standard.value(forKey: "profile_picture_url") as? String else {
            return nil
        }
        return Sender(senderId: userId,
                      displayName: displayName,
                      photoURL: "")
    }()

    var isLoggedIn: Bool?
        
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
    
    private var messageListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noChatsFound)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmAuth()
        listenMessages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    func confirmAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
//    private func insertNewMessage(_ message: Message) {
//        guard !messages.contains(message) else {
//            return
//        }
//
//        messages.append(message)
//        messages.sort()
//
//        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
//        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
//
//        messagesCollectionView.reloadData()
//
//        if shouldScrollToBottom {
//            DispatchQueue.main.async {
//                self.messagesCollectionView.scrollToBottom(animated: true)
//            }
//        }
//    }
    
    func listenMessages() {
        DatabaseManager.shared.allMessages() { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                self?.messages.sort()
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }

    
    func putMessageId() -> String? {
        guard let userEmail = UserDefaults.standard.value(forKey: "user_id") else {
            return nil
        }
        let dateString = Self.dateFormatter.string(from: Date())
        let identifier = "\(userEmail)_\(dateString)"
        print("created a message ID: \(identifier)")
        return identifier
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> CGSize {

      // 1
      return .zero
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> CGSize {

      // 2
      return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath,
      with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

      // 3
      return 0
    }

}


extension ChatViewController {
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
                self.messageInputBar.inputTextView.text = nil
                print("message was sent")
            }
            else {
                print("failed to send")
            }
        }
        
    }
    
    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {
        
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.gray
            ]
        )
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 35
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        // 1
        return isFromCurrentSender(message: message) ? .blue : .red
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        // 2
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        // 3
        return .bubbleTail(corner, .curved)
    }
}
