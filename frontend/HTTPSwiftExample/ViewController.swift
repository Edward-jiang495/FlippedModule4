let SERVER_URL = "http://10.8.27.223:8000" // change this for your server name!!!

import UIKit
import CoreMotion

class ViewController: UIViewController, URLSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view did load
        //bolding selected ml label
        if(toggleState.isOn){
            mlpLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
            cnnLabel.font = UIFont.boldSystemFont(ofSize: 16.0)

        }
        else{
            mlpLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            cnnLabel.font = UIFont.boldSystemFont(ofSize: 24.0)

        }
    }
    
    @IBOutlet weak var mlpLabel: UILabel!
    //mlp label
    
    @IBOutlet weak var cnnLabel: UILabel!
    //cnn label
    
    @IBOutlet weak var hotdog: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    //image view
    
    var imagePicker: UIImagePickerController!
    

    
    @IBOutlet weak var toggleState: UISwitch!
    //outlet for switch
    
    @IBAction func toggleML(_ sender: UISwitch) {
        //bolding the text based on selection
        
        if(sender.isOn){
            mlpLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
            cnnLabel.font = UIFont.boldSystemFont(ofSize: 16.0)

            print("ON")

        }
        else{
            mlpLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            cnnLabel.font = UIFont.boldSystemFont(ofSize: 24.0)

            print("OFF")

        }
    }
    
    
    
    @IBAction func takePhoto(_ sender: UIButton) {
        //function to take a photo
        
         imagePicker =  UIImagePickerController()
         imagePicker.delegate = self
         imagePicker.sourceType = .camera

         present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imagePicker.dismiss(animated: true, completion: nil)
            imageView.image = info[.originalImage] as? UIImage
        //delegate
        }
    
    
    @IBAction func hotdogPressed(_ sender: UIButton) {
        //is a hotdog pressed
        if toggleState.isOn{
            print("ON")
//            do mlp stuff
        }
        else{
            print("ON")
            //do cnn stuff

            
        }
    }
    
    
    @IBAction func notHotdogPressed(_ sender: UIButton) {
        //not a hotdog pressed
        if toggleState.isOn{
            print("ON")
            //do mlp stuff
        }
        else{
            print("ON")
            //do cnn stuff

            
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        //reset stuff
        
    }
    
    
    @IBAction func predict(_ sender: UIButton) {
//        predict stuff
        var image = imageView.image;
        //do something with the image
        var results = toggleState.isOn;
        if(results){
            hotdog.text = "Hotdog"
        }
        else{
            hotdog.text = "Not a hotdog"
        }
    }
    

}






