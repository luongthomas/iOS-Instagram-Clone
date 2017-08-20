//
//  Comment.swift
//  Instagram Voong
//
//  Created by Puroof on 8/19/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
