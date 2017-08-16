//
//  User.swift
//  Instagram Voong
//
//  Created by Puroof on 8/16/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let profileImageUrl: String
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
}
