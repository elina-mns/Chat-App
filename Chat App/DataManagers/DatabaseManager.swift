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
    
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
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
        
        dataBase.child("users").observeSingleEvent(of: .value, with: { snapshot in
            if var usersCollection = snapshot.value as? [[String: String]] {
                // append to user dictionary
                let newElement = [
                    "name": user.firstName + " " + user.lastName,
                    "email": user.safeEmail
                ]
                usersCollection.append(newElement)

                self.dataBase.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    completion(true)
                })
            }
            else {
                // create that array
                let newCollection: [[String: String]] = [
                    [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                ]
                self.dataBase.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    completion(true)
                })
            }
        })
    }
    
    func sendMessage(message: Message, completion: @escaping (_ success: Bool) -> Void) {
        //generate an unique ID to store messages
        dataBase.child("test/messages").childByAutoId().setValue(message.asDictionary()) { (error, _) in
            completion(error == nil)
        }
    }
    
    public func getAllConversationsList(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        dataBase.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }

                let lastMessageObject = LastMessage(date: date,
                                                         text: message,
                                                         isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: lastMessageObject)
            })
            completion(.success(conversations))
        })
    }
    
    public func conversationExists(iwth targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)

        dataBase.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }

            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }
    
    func receiveAllMessages(withId id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        //get everything from the folder "messages" that we placed previously
        dataBase.child("\(id)/messages").observe(.value) { (snapshot) in
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
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        dataBase.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }

    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        print("Deleting conversation with id: \(conversationId)")

        // Get all conversations for current user
        // delete conversation in collection with target id
        // reset those conversations for the user in database
        let ref = dataBase.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                        id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }

                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _  in
                    guard error == nil else {
                        completion(false)
                        print("faield to write new conversatino array")
                        return
                    }
                    print("deleted conversaiton")
                    completion(true)
                })
            }
        }
    }
}

