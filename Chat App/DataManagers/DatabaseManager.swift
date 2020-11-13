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
    
    static func changedEmail(email: String) -> String {
        var changedEmail = email.replacingOccurrences(of: ".", with: "-")
        changedEmail = changedEmail.replacingOccurrences(of: "@", with: "-")
        return changedEmail
    }
    
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
    
    func allMessages(completion: @escaping (Result<[Message], Error>) -> Void) {
        //get everything from the folder messages that we placed before
        dataBase.child("test/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            //trasform each element of array Dictionary to Message array
            let messages: [Message] = value.keys.compactMap({ key in
                guard let dictionary = value[key] as? [String: Any],
                      let senderDict = dictionary["sender"] as? [String: String],
                      let senderId = senderDict["senderId"],
                      let displayName = senderDict["displayName"],
                      let photoURL = senderDict["photoURL"],
                      let messageId = dictionary["messageId"] as? String,
                      let kind = dictionary["kind"] as? [String: String],
                      //let type = kind["type"] as? String,
                      let content = kind["content"],
                      let dateNumber = dictionary["sentDate"] as? Double else {
                    return nil
                }
                let date = Date(timeIntervalSinceReferenceDate: dateNumber)
                let sender = Sender(senderId: senderId, displayName: displayName, photoURL: photoURL)
                let messageKind: MessageKind = .text(content)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: messageKind)
            })
            completion(.success(messages))
        }
    }
}
