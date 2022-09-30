//
//  ViewController.swift
//  FoodVision
//
//  Created by Sekaye Knutson on 9/29/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    //outlets
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var objectTitle: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var confirmationImage: UIImageView!
    
    //properties
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)

    }
}

// MARK: - Image Picker Methods
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImg.image = chosenImg
            
            guard let convertedImage = CIImage(image: chosenImg)
            else { fatalError("failure to convert to CI Image") }
            detect(image: convertedImage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        //model setup
        let configuration = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: configuration).model)
        else { fatalError("loading CoreML model failed") }
        
        //request setup
        let MLRequest = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results
            else { fatalError("issue processing results from request") }
            
            if let firstResult = results.first {
                let objectID = firstResult.description
                print(objectID)
                if objectID.contains("hotdog") {
                    self.objectTitle.text = "A Hotdog!"
                    self.confirmationImage.tintColor = UIColor.systemGreen
                    self.backgroundView.backgroundColor = UIColor.systemGreen
                    UIImage(systemName: "checkmark.seal")
                } else {
                    self.objectTitle.text = "Not a Hotdog..."
                    self.backgroundView.backgroundColor = UIColor.systemRed
                    self.confirmationImage.tintColor = UIColor.systemRed
                    self.confirmationImage.image = UIImage(systemName: "xmark.circle.fill")
                }
            }
        }
        
        //handler setup
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([MLRequest])
        } catch { fatalError("failure handling request") }
    }
}

