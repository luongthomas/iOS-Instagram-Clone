//
//  HomePostCell.swift
//  Instagram Voong
//
//  Created by Puroof on 8/16/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit


protocol HomePostCellDelegate {
    func didTapComment(post: Post) 
}

class HomePostCell: UICollectionViewCell {

    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            guard let postImageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: postImageUrl)
            
            usernameLabel.text = post?.user.username
            
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            userProfileImageView.loadImage(urlString: profileImageUrl)
            
            // captionLabel.text = post?.caption
            
            setupAttributedCaption()
        }
    }
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)])
        
        attributedText.append(NSMutableAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)]))
        
        // separating the timestamp and the comments
        attributedText.append(NSMutableAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSMutableAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        
        self.captionLabel.attributedText = attributedText
    }

    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("•••", for: UIControlState.normal)
        button.setTitleColor(.black, for: UIControlState.normal)
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        button.setTitleColor(.black, for: UIControlState.normal)
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        button.setTitleColor(.black, for: UIControlState.normal)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        button.setTitleColor(.black, for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        button.setTitleColor(.black, for: UIControlState.normal)
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(optionsButton)
        addSubview(photoImageView)
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(captionLabel)
        
        photoImageView.anchor(userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        // Square photo view
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        
        userProfileImageView.anchor(topAnchor, left: leftAnchor, bottom: photoImageView.topAnchor, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        
        usernameLabel.anchor(topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
        optionsButton.anchor(topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 0)
        
        
        setupActionButtons()
        captionLabel.anchor(likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    @objc func handleComment() {
        print("Trying to show comments")
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendButton])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(photoImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
