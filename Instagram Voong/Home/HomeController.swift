//
//  HomeController.swift
//  Instagram Voong
//
//  Created by Puroof on 8/16/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit
import Firebase


private let reuseIdentifier = "Cell"

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    func didTapComment(post: Post) {
        print("Message coming from HomeController")
        print(post.caption)
        let layout = UICollectionViewFlowLayout()
        let commentsController = CommentsController(collectionViewLayout: layout)
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)

        // Register cell classes
        self.collectionView!.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }

    @objc func handleRefresh() {
        print("Handling Refresh..")
        
        posts.removeAll()
        
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    // Instagram title at top
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        print("Showing Camera")
        
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Username + userprofileimageview
        var height: CGFloat = 40 + 8 + 8
        
        height += view.frame.width
        
        // for buttonActionBar
        height += 50
        
        // for comment section
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }

    var posts = [Post]()
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUid(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
        
    }
    
    // Gets a dictionary of the users the current user is following.  Then we fetch posts of each user
    fileprivate func fetchFollowingUserIds() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("following").child(currentUserUid)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUid(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
            
            
        }) { (err) in
            print("Failed to get current user's following people", err)
            return
            
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                
                // Stop the spinner
                self.collectionView?.refreshControl?.endRefreshing()
                
                guard let dictionary = value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                
                // post needs to be a var to have its members changed
                post.id = key
                
                self.posts.append(post)
            })
            
            // Sort posts by the latest post first
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate.compare(post2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
            
        }, withCancel: { (err) in
            print("Failed to fetch posts: ", err)
        })
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
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.delegate = self
    
        // Configure the cell
        cell.post = posts[indexPath.item]
        
        return cell
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


