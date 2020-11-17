//
//  DatabaseManager.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-06.
//

import Foundation
import FirebaseDatabase
import MessageKit

enum DatabaseError: Error {
    case failedToFetch
}

class DatabaseManager {
    static let shared = DatabaseManager()
    let dataBase = Database.database().reference()
    
    
    func addUser(user: ProfileInfo, completion: @escaping (Bool) -> Void) {
        dataBase.child(user.id).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "email": user.email
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed to write to Database")
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    func sendMessage(message: Message, completion: @escaping (_ success: Bool) -> Void) {
        //generate an unique ID to store messages
        dataBase.child("test/messages").childByAutoId().setValue(message.asDictionary()) { (error, _) in
            completion(error == nil)
        }
    }
    
    func receiveAllMessages(completion: @escaping (Result<[Message], Error>) -> Void) {
        //get everything from the folder "messages" that we placed previously
        dataBase.child("test/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            //trasform each element of array of Dictionary to Message array
            let messages: [Message] = value.keys.compactMap({ key in
                guard let dictionary = value[key] as? [String: Any],
                      let senderDict = dictionary["sender"] as? [String: String],
                      let senderId = senderDict["senderId"],
                      let displayName = senderDict["displayName"],
                      let photoURL = senderDict["photoURL"],
                      let messageId = dictionary["messageId"] as? String,
                      let kind = dictionary["kind"] as? [String: String],
                      let type = kind["type"],
                      let content = kind["content"],
                      let dateNumber = dictionary["sentDate"] as? Double else {
                    return nil
                }
                let date = Date(timeIntervalSinceReferenceDate: dateNumber)
                let sender = Sender(senderId: senderId, displayName: displayName, photoURL: photoURL)
                var messageKind: MessageKind = .text(content)
                switch type {
                case "text":
                    messageKind = .text(content)
                case "photo":
                    if let url = URL(string: content) {
                        let mediaItem = Media(url: url, image: nil, size: CGSize(width: 70, height: 70))
                        messageKind = .photo(mediaItem)
                    }
                case "video":
                    if let url = URL(string: content) {
                        let mediaItem = Media(url: url, image: nil, size: CGSize(width: 70, height: 70))
                        messageKind = .video(mediaItem)
                    }
                // for gifs
                case "custom":
                    messageKind = .custom(content)
                default:
                    messageKind = .text(content)
                }
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: messageKind)
            })
            completion(.success(messages))
        }
    }
}
