//
//  SelectedChatVC.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-09.
//

import UIKit
import MessageKit

class SelectedChatVC: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

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
    
    var messages = [Message]()
    var sender = Sender(senderId: "1", displayName: "Jopa", photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("Test hello")))
    }

    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    

}
