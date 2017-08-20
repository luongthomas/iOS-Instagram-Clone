//
//  CommentsController.swift
//  Instagram Voong
//
//  Created by Puroof on 8/19/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // so the view will only show enough space for the comments
        // -50 is for the space the comment text field is using
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        // adjust the scroll bar to accomodate for the text field space
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        collectionView?.backgroundColor = .red

        // Register cell classes
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = .white
        
        fetchComments()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    // lazy var for this variable to have access to the self variable, which we can use to access commentTextField
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        // Submit Button
        let submitButton = UIButton(type: UIButtonType.system)
        submitButton.setTitle("Submit", for: UIControlState.normal)
        submitButton.setTitleColor(.black, for: UIControlState.normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        containerView.addSubview(submitButton)
        submitButton.anchor(containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 0)
        
        // Comment Text Field
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        return containerView
    }()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        return textField
    }()
    
    
    @objc func handleSubmit() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postId = self.post?.id ?? ""
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        let ref = Database.database().reference().child("comments").child(postId).childByAutoId()
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comments", err)
                return
            }
            
            print("Successfully inserted comment")
        }
    }
    
    
    // all views have this inputAccessoryView that allow you to type in
    // important to return a variable that holds a reference to the object
    // Benefits of using inputAccessoryView as a textfield holder, is that
    //  UIKit will handle the positioning of that view for us
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    // allows the inputAccessoryView to appear first
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var comments = [Comment]()
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(DataEventType.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let comment = Comment(dictionary: dictionary)
            print(comment.text, comment.uid)
            
            self.comments.append(comment)
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("failed to observe comments")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
    
        // Configure the cell
        // Remember to cast cell as CommentCell forcefully
        cell.comment = self.comments[indexPath.item]
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
