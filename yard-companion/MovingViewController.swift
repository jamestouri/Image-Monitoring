//
//  MovingViewController.swift
//  yard-companion
//
//  Created by James touri on 2/4/18.
//  Copyright © 2018 yard-companion. All rights reserved.
//

import UIKit
import ARKit
import Vision
import Foundation

class MovingViewController: UIViewController {

    @IBOutlet weak var contentView: ARSCNView!
    private var scanTimer: Timer?
    
    //Finding the image it is looking for
    private var imageOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .right
        case .landscapeRight: return .down
        case .portraitUpsideDown: return .left
        case .unknown: fallthrough
        case .faceUp: fallthrough
        case .faceDown: fallthrough
        case .landscapeLeft: return .up
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARWorldTrackingConfiguration()
        
        contentView.session.run(configuration)
        
        scanTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(scanningFaces), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func scanningFaces() {
        
        
        guard let capturedImage = contentView.session.currentFrame?.capturedImage else { return }
        let image = CIImage.init(cvPixelBuffer: capturedImage)

//        guard let capturedImage = contentView.session.currentFrame?.capturedImage else { return }
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            DispatchQueue.main.async {
                if let faces = request.results as? [VNFaceObservation] {
                    for face in faces {
                        let faceView = UIView(frame: self.faceFrame(from: face.boundingBox))
                        //Calling NEC
                        print("Face Found")
                        self.detection()
                        
                        
                    }
                }
            }
        }
        
        DispatchQueue.global().async {
            try? VNImageRequestHandler(ciImage: image, orientation: self.imageOrientation).perform([detectFaceRequest])
        }
       
    }
    
    // Taking Screenshot of screen to process through NEC Detection API
//    func screenShot() {
//        UIGraphicsBeginImageContext(view.frame.size)
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
//        theImage = UIGraphicsGetImageFromCurrentImageContext()
//        var bitImage: NSData = UIImageJPEGRepresentation(theImage!, 1.0)?.base64EncodedData() as! NSData
//        UIGraphicsEndImageContext()
//    }
    
    func detection () {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        var theImage = UIGraphicsGetImageFromCurrentImageContext()
        let bitImage: NSString = UIImageJPEGRepresentation(theImage!, 1.0)?.base64EncodedString(options: []) as! NSString
        UIGraphicsEndImageContext()
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
                "image": bitImage,
                "detectFaceLimit": 4]
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
                print(responseJSON["resData"])
                if responseJSON["resData"] == nil {
                    
                    
                }
                
                }
                
            }
        
        
        task.resume()
        
    }

    private func faceFrame(from boundingBox: CGRect) -> CGRect {
        
        let origin = CGPoint(x: boundingBox.minX * contentView.bounds.width, y: (1 - boundingBox.maxY) * contentView.bounds.height)
        let size = CGSize(width: boundingBox.width * contentView.bounds.width, height: boundingBox.height * contentView.bounds.height)
        
        return CGRect(origin: origin, size: size)
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

extension MovingViewController: ARSCNViewDelegate {
    //implement ARSCNViewDelegate functions for things like error tracking
}
