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
    
    public var changedEmail: String {
        var changedEmail = email.replacingOccurrences(of: ".", with: "-")
        changedEmail = changedEmail.replacingOccurrences(of: ".", with: "-")
        return changedEmail
    }
    public var profilePicFileName: String {
        return "\(changedEmail)_profile_pic.png"
    }
}
