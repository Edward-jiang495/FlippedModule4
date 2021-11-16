//let SERVER_URL = "http://10.8.27.223:8000" // change this for your server name!!!
let SERVER_URL = "http://10.8.106.203:8000"

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
        epoch.text = "\(Int(epochSlider.value)) epochs";
    }
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var mlState: UISegmentedControl!
    
    @IBOutlet weak var resultText: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var epoch: UILabel!
    
    @IBAction func epochSlider(_ sender: UISlider) {
        //sliders to change epoch value
        let currentValue = Int(sender.value)
        epoch.text = "\(currentValue) epochs"
    }
    
    
    //MARK: Button actions that open camera
    @IBAction func hotdog(_ sender: UIButton) {
        openCamera(title: "hotDog")
    }
    
    @IBAction func notHotdog(_ sender: UIButton) {
        openCamera(title: "notHotDog")

    }
    
    @IBAction func predict(_ sender: UIButton) {
        //predict based on pics
        openCamera(title: "predict")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
        let base64EncondedImage = convertImageToBase64(image: info[.originalImage] as! UIImage)
        if(imagePicker.title == "notHotDog"){
            print("Sending negative train data example.")
            sendTrainData(image: base64EncondedImage, target: "false");
        }else if(imagePicker.title == "hotDog"){
            print("Sending positive train data example.")
            sendTrainData(image: base64EncondedImage, target: "true");
        }else if(imagePicker.title == "predict"){
            print("Predicting image.")
            getPrediction(image: base64EncondedImage)
        }else{
            print("No valid action for image.")
        }
    }
    
    
    @IBAction func reset(_ sender: UIButton) {
        //reset model
        resetModel()
    }
    
    

    
    @IBAction func train(_ sender: UIButton) {
        //train with previously uploaded pics
        trainModel()

    }
    
    //MARK: API calls
    func sendTrainData(image: String,target: String){
        var model = "CNN";
        if mlState.selectedSegmentIndex == 0{
            model = "MLP";
        }
        let baseURL = "\(SERVER_URL)/\(model)/UploadImage";
      
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["image":image,"target":target]
        print(jsonUpload)
        
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
            model = "MLP";
        }
        let baseURL = "\(SERVER_URL)/\(model)/predict";
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
            model = "MLP";
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
            model = "MLP";
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
    
    //MARK: Open camera
    
    func openCamera(title:String){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.title = title
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Image Conversion to Base64
    
    //I used the links below to learn how to convert an image to base64
    //https://developer.apple.com/forums/thread/110240
    //https://www.appsdeveloperblog.com/uiimage-base64-encoding-and-decoding-in-swift/
    //https://stackoverflow.com/questions/11251340/convert-between-uiimage-and-base64-string
    func convertImageToBase64(image:UIImage) -> String{
        let imageData = image.jpegData(compressionQuality: 1)
        
        if let imageBase64String = imageData?.base64EncodedString(){
            return imageBase64String
        }else{
            print("Could not encode image to Base64")
        }
        
        return "";
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
