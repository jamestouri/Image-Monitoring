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
    var success = true
    var theImage = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Open video
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        while(success == true) {
            
            // create post request
            let url = URL(string: "http://13.231.67.97/developerweek/api/v1.0/tenants/nec/if102008/root/json")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            // insert json data to the request
            var requestParameters = [
                "reqHeader": [
                    "reqDatetime": "{0:%Y/%m/%d %H:%M:%S}",
                    "deviceID": 12345],
                "reqData": [
                    "image": theImage,
                    "detectFaceLimit": 8]
            ]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: requestParameters)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
            }
            
            task.resume()
            
        }
    }
    
    
    
    
    
    
}
