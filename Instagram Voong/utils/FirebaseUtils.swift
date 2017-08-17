//
//  FirebaseUtils.swift
//  Instagram Voong
//
//  Created by Puroof on 8/17/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUid(uid: String, completion: @escaping (User) -> ()) {
        print("Fetching uid with uid: ", uid)
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
        }) { (err) in
            print("Failed to fetch posts: ", err)
        }
        
        
    }
}
