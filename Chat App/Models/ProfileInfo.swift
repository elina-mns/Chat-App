//
//  ProfileInfo.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-05.
//

import Foundation

struct ProfileInfo {
    let firstName: String
    let lastName: String
    let email: String
    let id: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = email.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public var profilePicFileName: String {
        return "\(id)_profile_pic.png"
    }
}

extension ProfileInfo {
    
    init?(userId: String, from profileInfoDict: [String: Any]) {
        guard let firstName = profileInfoDict["first_name"] as? String,
              let lastName = profileInfoDict["last_name"] as? String,
              let email = profileInfoDict["email"] as? String else {
            return nil
        }
        self.id = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
