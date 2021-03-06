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
import GiphyUISDK
import GiphyCoreSDK


class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    let giphy = GiphyViewController()
    
    var selectedContentType: GPHContentType?

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
            return nil
        }
        let photoURL = UserDefaults.standard.value(forKey: "profile_picture_url") as? String ?? ""
        return Sender(senderId: userId,
                      displayName: displayName,
                      photoURL: photoURL)
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
    
    private var messageListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noChatsFound)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.register(GifCollectionViewCell.self)
        initializeHideKeyboard()
        
        let background = UIImageView();
        background.image = UIImage(named: "1");
        background.contentMode = .scaleToFill
        self.messagesCollectionView.backgroundView = background
        
        // a button for viewing a gif view controller
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.gifButtonTapped()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
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
    
    func listenMessages() {
        DatabaseManager.shared.receiveAllMessages() { [weak self] result in
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
                self?.showAlert(title: "Error",
                                message: "Problem with fetching new messages from server. Please try again later.",
                                actionForOk: nil)
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
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendTextMessage(text: text)
    }
    
    func sendTextMessage(text: String) {
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
        sendMessage(message: message)
    }
    
    func sendGifMessage(media: GPHMedia) {
        guard let messageId = putMessageId(),
            let sender = self.sender else {
            return
        }
        let gifId = media.id
        //Send a message
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .custom(gifId))
        sendMessage(message: message)
    }
    
    func sendMessage(message: Message) {
        DatabaseManager.shared.sendMessage(message: message) { success in
            if success {
                self.messageInputBar.inputTextView.text = nil
                print("message was sent")
            } else {
                self.showAlert(title: "Error",
                               message: "Failed to send a message. Please try again later.",
                               actionForOk: nil)
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
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let urlString = (message.sender as? Sender)?.photoURL, let url = URL(string: urlString) else { return }
        avatarView.loadFromURL(photoUrl: url)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .darkGray : .lightGray
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return true
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        return CustomMessageSizeCalculator(layout: messagesCollectionView.messagesCollectionViewFlowLayout)
    }
    
    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        let gifCell = messagesCollectionView.dequeueReusableCell(GifCollectionViewCell.self, for: indexPath)
        gifCell.configure(with: message, at: indexPath, and: messagesCollectionView)
        return gifCell
    }
}

// showing a GIF View Controller

extension ChatViewController: GiphyDelegate {
    
    @objc func gifButtonTapped() {
        let giphy = GiphyViewController()
        GiphyViewController.trayHeightMultiplier = 0.7
        giphy.shouldLocalizeSearch = true
        giphy.delegate = self
        giphy.dimBackground = true
        giphy.modalPresentationStyle = .overCurrentContext
   
        present(giphy, animated: true, completion: nil)
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        self.selectedContentType = giphy.selectedContentType
        dismiss(animated: true, completion: { [weak self] in
            self?.sendGifMessage(media: media)
        })
        GPHCache.shared.clear()
    }
    
    func addGifToChat(text: String? = nil, media: GPHMedia? = nil, user: ProfileInfo) {
        let indexPath = IndexPath(row: messages.count, section: 0)
        UIView.animate(withDuration: 0, animations: { [weak self] in
            self?.messagesCollectionView.insertItems(at: [indexPath])
        })
        messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func didDismiss(controller: GiphyViewController?) {
        giphy.dismiss(animated: true, completion: nil)
    }
}
