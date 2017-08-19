//
//  CameraController.swift
//  Instagram Voong
//
//  Created by Puroof on 8/19/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .blue
        
        setupCaptureSession()
        
        setupHUD()
    }
    
    let captureButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleDismiss), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    @objc func handleCapturePhoto() {
        print("Handle capture Photo" )
    }
    
    @objc func handleDismiss() {
        print("Handle dismiss" )
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupHUD() {
        view.addSubview(captureButton)
        captureButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 24, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        view.addSubview(dismissButton)
        dismissButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 50)
    }
    
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        // 1. setup inputs
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // prevents crashing
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
        } catch let err {
            print("Could not setup camera input", err)
        }
        
        
        // 2. setup outputs
        let output = AVCapturePhotoOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
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
