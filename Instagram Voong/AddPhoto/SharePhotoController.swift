//
//  SharePhotoController.swift
//  Instagram Voong
//
//  Created by Puroof on 8/14/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {

    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    fileprivate func setupImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 84, heightConstant: 0)
        
        containerView.addSubview(textView)
        textView.anchor(containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    @objc func handleShare() {
        guard let caption = textView.text, caption.characters.count > 0 else { return }
        guard let image = selectedImage else { return }
        
        // compressing image for upload
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Just a random string of number and letters
        let filename = NSUUID().uuidString
        Storage.storage().reference().child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                print("Failed to upload post image: ", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded post image: ",  imageUrl)
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
    }
    
    // static allows it to be accessed anywhere
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    // Save image url to database
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String: Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("Failed to save post to DB ", err)
                return
            }
            
            print("Successfully uploaded image to DB")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
