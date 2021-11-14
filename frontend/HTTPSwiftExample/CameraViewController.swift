//
//  CameraViewController.swift
//  HTTPSwiftExample
//
//  Created by Zhengran Jiang on 11/13/21.
//  Copyright © 2021 Eric Larson. All rights reserved.
//

import UIKit


class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, URLSessionDelegate{
    
    var imagePicker: UIImagePickerController!



    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imagePicker.dismiss(animated: true, completion: nil)
            imageView.image = info[.originalImage] as? UIImage
        }

    
    @IBAction func takePhoto(_ sender: UIButton) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func sendToServer(_ sender: UIButton) {
        //send image to server
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
