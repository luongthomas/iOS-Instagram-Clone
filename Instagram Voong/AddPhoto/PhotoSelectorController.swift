//
//  PhotoSelectorController.swift
//  Instagram Voong
//
//  Created by Puroof on 8/10/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var selectedImage: UIImage?
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        collectionView?.backgroundColor = .yellow
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        fetchPhotos()
        
    }
    
    // Scroll to top after selecting item
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView?.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        
        // Sort images newest first
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.fetchLimit = 30
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        // Background thread, to reduce wait time to fetch all images
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        // Back to the main thread, now call UI Code
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    }
                })
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    var header: PhotoSelectorHeader?
    
    // needs size or wont show at all
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        
        header.photoImageView.image = selectedImage
        
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.default, options: nil, resultHandler: { (image, info) in
                    
                    header.photoImageView.image = image
                })
            }
        }
        
        
        
        
        return header
    }
    
    // 1 pixel space between header and the other collectionviewcells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func setupNavigationButtons() {
        // changes from default blue to black
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // 1 pixel horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // 1 pixel vertical space
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4 //factors in vertical spacing
        return CGSize(width: width, height: width)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
    
        // Configure the cell
        cell.photoImageView.image = images[indexPath.item]
        
        
        return cell
    }

}
