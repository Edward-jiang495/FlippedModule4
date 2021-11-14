//
//  CameraViewController.swift
//  HTTPSwiftExample
//
//  Created by Zhengran Jiang on 11/13/21.
//  Copyright © 2021 Eric Larson. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    lazy var videoManager:VideoAnalgesic! = {
//        create video analgesic
        let tmpManager = VideoAnalgesic(mainView: self.view)
        tmpManager.setCameraPosition(position: .front)
        return tmpManager
    }()
    var cameraFront:Bool = true;
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
//        set running code
        
        if !videoManager.isRunning{
            videoManager.start()
//            start running
        }

        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool){
        
        DispatchQueue.main.async {
            self.videoManager.shutdown()

        }
        super.viewDidDisappear(animated)
        
    }


    @IBAction func toggleCamera(_ sender: UIButton) {
        if cameraFront{
            videoManager.setCameraPosition(position: .back)
            cameraFront = !cameraFront
        }
        else{
            videoManager.setCameraPosition(position: .front)
            cameraFront = !cameraFront
        }
    }
    
    func processImage(inputImage:CIImage) -> CIImage{
        
        //here we process the images
        return inputImage
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
