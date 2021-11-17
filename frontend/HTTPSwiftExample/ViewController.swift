//let SERVER_URL = "http://10.8.27.223:8000" // change this for your server name!!!
let SERVER_URL = "http://192.168.1.66:8000"

import UIKit
import CoreMotion

class ViewController: UIViewController, URLSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 600.0
        sessionConfig.timeoutIntervalForResource = 600.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    @IBOutlet weak var epochSlider: UISlider!
    let operationQueue = OperationQueue()
    
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
        let base64EncondedImage = convertImageToBase64(image: imageView.image as! UIImage)
        if(imagePicker.title == "notHotDog"){
            print("Sending negative train data example.")
            DispatchQueue.main.async {
                self.resultText.text = "Uploading Negative Sample..."
            }
            sendTrainData(image: base64EncondedImage, target: false);
        }else if(imagePicker.title == "hotDog"){
            print("Sending positive train data example.")
            DispatchQueue.main.async {
                self.resultText.text = "Uploding Positive Sample..."
            }
            sendTrainData(image: base64EncondedImage, target: true);
        }else if(imagePicker.title == "predict"){
            print("Predicting image.")
            DispatchQueue.main.async {
                self.resultText.text = "predicting..."
            }
            getPrediction(image: base64EncondedImage)
        }else{
            print("No valid action for image.")
        }
//        print("SIZE")
//        print(imageView.image!.size.width)
//        print(imageView.image!.size.height)
        print(imageView.image!.size.width * imageView.image!.scale)
        print(imageView.image!.size.height * imageView.image!.scale)


        

    }
    
    
    @IBAction func reset(_ sender: UIButton) {
        //reset model
        resetModel()
    }
    
    @IBAction func train(_ sender: UIButton) {
        //train with previously uploaded pics
        trainModel()
        var model = ""
        if mlState.selectedSegmentIndex == 0{
            model = "Xception"
        }
        else if mlState.selectedSegmentIndex == 1{
            model = "Inception ResNet v2"
        }
        self.resultText.text = "Training \(model)..."

    }
    
    //MARK: API calls
    func sendTrainData(image: String,target: Bool){
        var model = "Inception";
        if mlState.selectedSegmentIndex == 0{
            model = "Xception";
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
                    DispatchQueue.main.async {
                        self.resultText.text = "Training data uploaded";
                    }
//                    print(jsonDictionary["feature"]!)
//                    print(jsonDictionary["label"]!)
                }

        })
        
        postTask.resume() // start the task
    }
    
    func getPrediction(image:String){
        var model = "Inception";
        if mlState.selectedSegmentIndex == 0{
            model = "Xception";
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
                            
                            if let labelResponse = jsonDictionary["prediction"] as? String{
                                self.showResult(result: labelResponse)
                            }else{
                                self.showResult(result: "Error predicting.")
                            }
                                

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func resetModel(){
        var model = "Inception";
        if mlState.selectedSegmentIndex == 0{
            model = "Xception";
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
                            DispatchQueue.main.async {
                                self.resultText.text = "Model reset"
                            }

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func trainModel(){
        var model = "Inception";
        if mlState.selectedSegmentIndex == 0{
            model = "Xception";
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
                            if var val_acc = jsonDictionary["val_acc"]{
                                val_acc = round(val_acc as! Double * 1000) / 10.0
                                DispatchQueue.main.async {
                                    self.resultText.text = "Training finished with \(val_acc)% validation accuracy";
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.resultText.text = "Error when training.";
                                }
                            }
                            
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
//        resize uiimage here to 256, 256 pixels
        let size = CGSize(width: 256,height: 256)
        let imageResized = resizeImage(image: image, targetSize: size)
        DispatchQueue.main.async {
            self.imageView.image = imageResized
            print("UPDATE RESCCALE")
            print(imageResized!.size.width * imageResized!.scale)
            print(imageResized!.size.height * imageResized!.scale)

        }
        let imageData = imageResized?.jpegData(compressionQuality: 1)
        
//        let imageData = image.jpegData(compressionQuality: 1)
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
    
////    https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }


    
}
