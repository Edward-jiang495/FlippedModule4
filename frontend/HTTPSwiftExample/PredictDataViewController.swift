//
//  PredictDataViewController.swift
//  HTTPSwiftExample
//
//  Created by Zhengran Jiang on 11/14/21.
//  Copyright © 2021 Eric Larson. All rights reserved.
//

import UIKit

class PredictDataViewController: UIViewController {
    
    lazy var videoManager:VideoAnalgesic! = {
//        create video analgesic
        let tmpManager = VideoAnalgesic(mainView: self.view)
        tmpManager.setCameraPosition(position: .back)
        return tmpManager
    }()

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
    
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
//        process image here
        
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
