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
    
    func addUser(user: ProfileInfo) {
        dataBase.child(user.id).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}
