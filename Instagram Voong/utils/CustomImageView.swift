//
//  CustomImageView.swift
//  Instagram Voong
//
//  Created by Puroof on 8/15/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        // Using cache to reduce calls
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image: ", err)
                return
            }
            
            // Since the calls are happening asynchronously
            // data coming in will be not in order, so it will check if
            // it is the expected post url otherwise keep waiting
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            // Suspends the task and must resume
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
