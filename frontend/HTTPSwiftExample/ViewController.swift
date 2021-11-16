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
    
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    let operationQueue = OperationQueue()
    
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
    
    func displayLabelResponse(_ response:String){
        switch response {
        case "['up']":
            blinkLabel(upArrow)
            break
        case "['down']":
            blinkLabel(downArrow)
            break
        case "['left']":
            blinkLabel(leftArrow)
            break
        case "['right']":
            blinkLabel(rightArrow)
            break
        default:
            print("Unknown")
            break
        }
    }
    
    func blinkLabel(_ label:UILabel){
        DispatchQueue.main.async {
            self.setAsCalibrating(label)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setAsNormal(label)
            })
        }
        
    }
    
    func getPrediction(_ image:[Double]){
        var model = "CNN";
        if(toggleState.isOn){
            model = "MLP";
        }
        let baseURL = "\(SERVER_URL)/\(model)/PredictOne";
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["image":image]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            let labelResponse = jsonDictionary["prediction"]!
                            print(labelResponse)
                            self.displayLabelResponse(labelResponse as! String)

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }
    

}






