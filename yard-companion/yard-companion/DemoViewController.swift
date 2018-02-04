//
//  DemoViewController.swift
//  yard-companion
//
//  Created by James touri on 2/3/18.
//  Copyright © 2018 yard-companion. All rights reserved.
//

import UIKit
import AVFoundation
import Vision


class DemoViewController: UIViewController {
    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()

    }
    
    
    
    
}
