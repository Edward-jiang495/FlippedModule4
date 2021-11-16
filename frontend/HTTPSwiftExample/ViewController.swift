let SERVER_URL = "http://10.8.27.223:8000" // change this for your server name!!!

import UIKit
import CoreMotion

class ViewController: UIViewController, URLSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    @IBOutlet weak var epochSlider: UISlider!
    let operationQueue = OperationQueue()
    var isHotdog:Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var mlState: UISegmentedControl!
    
    @IBOutlet weak var resultText: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var epoch: UILabel!
    
    @IBAction func epochSlider(_ sender: UISlider) {
        //sliders to change epoch value
        let currentValue = Int(sender.value)
        epoch.text = "\(currentValue)"
    }
    
    
    @IBAction func hotdog(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        isHotdog = true
        present(imagePicker, animated: true, completion: nil)


    }
    
    
    @IBAction func notHotdog(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        isHotdog = false
        present(imagePicker, animated: true, completion: nil)
        


    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imagePicker.dismiss(animated: true, completion: nil)
            imageView.image = info[.originalImage] as? UIImage
            if mlState.selectedSegmentIndex == 0 {
                print("MLP sent")
//                if isHotdog{
//
//                }
//                else{
//
//                }
//                sendFeatures(image: ciImage!)
            }
            else if mlState.selectedSegmentIndex == 1 {
                print("CNN sent ")
//                if isHotdog{
//
//                }
//                else{
//
//                }
//                sendFeatures(image: ciImage!)
            }
            else{
                print("ERROR")
            }
        }
    
    
    @IBAction func reset(_ sender: UIButton) {
        //reset model
        if mlState.selectedSegmentIndex == 0 {
            print("MLP")
        }
        else if mlState.selectedSegmentIndex == 1 {
            print("CNN")
        }
        else{
            print("ERROR")
        }
    }
    
    
    @IBAction func predict(_ sender: UIButton) {
        //predict based on pics
        if(imageView.image != nil){
            let image:UIImage = imageView.image!
            let imageData = image.jpegData(compressionQuality: 1)
            let imageBase64String = imageData?.base64EncodedString()
            print(imageBase64String ?? "Could not encode image to Base64")

            getPrediction(image: imageBase64String!)
            
//            if mlState.selectedSegmentIndex == 0 {
//                print("MLP")
//
////                getPrediction(image: ciImage!)
//            }
//            else if mlState.selectedSegmentIndex == 1 {
//                print("CNN")
////                getPrediction(image: ciImage!)
//            }
//            else{
//                print("ERROR")
//            }
        }
        else{
            self.showResult(result: "Input image cannot be empty")
        }
    }
    
    @IBAction func train(_ sender: UIButton) {
        //train with given pics
        trainModel()
//        if mlState.selectedSegmentIndex == 0 {
//            print("MLP")
//            trainModel()
//
////               train func
//        }
//        else if mlState.selectedSegmentIndex == 1 {
//            print("CNN")
////            var ciImage = CIImage(image: imageView.image!)
////                train func
//        }
//        else{
//            print("ERROR")
//        }
//


    }
    
    //MARK: API calls
    func sendFeatures(image: String){
        var model = "CNN";
        if mlState.selectedSegmentIndex == 0{
            model = "CNN";
        }
        let baseURL = "\(SERVER_URL)/\(model)/AddImage";
      
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["image":image]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
//
//                    print(jsonDictionary["feature"]!)
//                    print(jsonDictionary["label"]!)
                }

        })
        
        postTask.resume() // start the task
    }
    
    func getPrediction(image:String){
        var model = "CNN";
        if mlState.selectedSegmentIndex == 0{
            model = "CNN";
        }
        let baseURL = "\(SERVER_URL)/\(model)/AddImage";
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
                            self.showResult(result: labelResponse as! String)

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func resetModel(){
        var model = "CNN";
        if mlState.selectedSegmentIndex == 0{
            model = "CNN";
        }
        let baseURL = "\(SERVER_URL)/\(model)/reset";
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = [:]
        
        
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
                           

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func trainModel(){
        var model = "CNN";
        if mlState.selectedSegmentIndex == 0{
            model = "CNN";
        }
        let baseURL = "\(SERVER_URL)/\(model)/train";
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["epochs":Int(epochSlider.value)]
        
        
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
                            

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func showResult(result:String){
        DispatchQueue.main.async {
            self.resultText.text = result
        }
        
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
