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

class MovingViewController: UIViewController {

    @IBOutlet weak var contentView: ARSCNView!
    private var scannedFaceViews = [UIView]()
    var theImage: UIImage? = nil
    private var scanTimer: Timer?

    
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
        
        //remove the test views and empty the array that was keeping a reference to them
        _ = scannedFaceViews.map { $0.removeFromSuperview() }
        scannedFaceViews.removeAll()
        
//        guard let capturedImage = contentView.session.currentFrame?.capturedImage else { return }
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            print("3")
            DispatchQueue.main.async {
                if ((request.results as? [VNFaceObservation]) != nil) {
                    print("Found a face")
                    self.screenShot()
                    
                    if self.theImage != nil {
                        self.detection()
                    } else {
                        print("restart")
                    }
                }
            }
        }
       
    }
    
    // Taking Screenshot of screen to process through NEC Detection API
    func screenShot() {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func detection () {
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
                var number_of_faces = responseJSON["detectFaceLimit"]
                
            }
        }
        
        task.resume()
        
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
