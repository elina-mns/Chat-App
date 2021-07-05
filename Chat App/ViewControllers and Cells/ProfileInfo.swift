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
    
    public var profilePicFileName: String {
        return "\(id)_profile_pic.png"
    }
}
