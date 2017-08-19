//
//  Post.swift
//  Instagram Voong
//
//  Created by Puroof on 8/15/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    let user: User
    let caption: String
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
