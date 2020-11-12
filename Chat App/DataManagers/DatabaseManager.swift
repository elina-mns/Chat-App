//
//  DatabaseManager.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-06.
//

import Foundation
import FirebaseDatabase

class DatabaseManager {
    static let shared = DatabaseManager()
    private let dataBase = Database.database().reference()
    
    func addUser(user: ProfileInfo, completion: @escaping (Bool) -> Void) {
        dataBase.child(user.id).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed to write to Database")
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    func sendMessage(message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}
