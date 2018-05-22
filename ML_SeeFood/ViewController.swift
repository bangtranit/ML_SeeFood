//
//  ViewController.swift
//  ML_SeeFood
//
//  Created by Tran Thanh Bang on 2018/05/22.
//  Copyright © 2018年 Tran Thanh Bang. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var checkImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    
    @IBAction func onClickOpenCamera(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            checkImageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else{fatalError("Could not convert UIImage to CIImage")}
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image : CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            print(topResult.identifier)
            DispatchQueue.main.async {
                self.navigationItem.title = topResult.identifier
                self.navigationController?.navigationBar.barTintColor = UIColor.green
                self.navigationController?.navigationBar.isTranslucent = false
            }
            /*
             if topResult.identifier.contains("hotdog") {
             DispatchQueue.main.async {
             self.navigationItem.title = "Hotdog!"
             self.navigationController?.navigationBar.barTintColor = UIColor.green
             self.navigationController?.navigationBar.isTranslucent = false
             
             
             }
             }
             else {
             DispatchQueue.main.async {
             self.navigationItem.title = "Not Hotdog!"
             self.navigationController?.navigationBar.barTintColor = UIColor.red
             self.navigationController?.navigationBar.isTranslucent = false
             
             }
             }
             */
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
    }
}



