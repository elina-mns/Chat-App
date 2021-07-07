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


class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    //MARK: Properties
    
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
    private var conversationId: String?
    public let otherUserEmail: String
    var isNewConversation = false
        
    let noChatsFound: UILabel = {
        let label = UILabel()
        label.text = "No chats found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    var background: UIImageView = {
        let background = UIImageView()
        background.image = UIImage(named: "1")
        background.contentMode = .scaleToFill
        return background
    }()
    
    let activityIndicator = JGProgressHUD(style: .light)
    
    private var messageListener: ListenerRegistration?
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noChatsFound)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.register(GifCollectionViewCell.self)
        initializeHideKeyboard()
        messagesCollectionView.backgroundView = background
        configureMessageBarView()
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmAuth()
        if let conversationId = conversationId {
            listenMessages(id: conversationId)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func configureMessageBarView() {
        // a button for viewing a gif view controller
        let button = InputBarButtonItem()
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.tintColor = .purple
        button.onTouchUpInside { [weak self] _ in
            self?.gifButtonTapped()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.inputTextView.placeholderLabel.text = " Message..."
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.rightStackView.isLayoutMarginsRelativeArrangement = true
    }

    func confirmAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func listenMessages(id: String) {
        DatabaseManager.shared.receiveAllMessages(withId: id, completion: { [weak self] result in
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
        })
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
      return .zero
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> CGSize {
      return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath,
      with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
      return 0
    }
}

     //MARK: Number of sections, inputbar, send text message, send GIF message

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
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: title ?? "User", firstMessage: message, completion:  { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenMessages(id: newConversationId)
                    self?.messageInputBar.inputTextView.text = nil
                }
                else {
                    print("process failed")
                }
            })
        } else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                }
                else {
                    print("process failed")
                }
            })
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

// MARK: - Configure Chat appearance

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

// MARK: - Show a GIF View Controller

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
