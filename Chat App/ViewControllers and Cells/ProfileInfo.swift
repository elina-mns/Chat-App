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
