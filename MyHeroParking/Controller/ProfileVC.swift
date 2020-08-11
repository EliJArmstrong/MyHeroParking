//
//  ProfileVC.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/21/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: RoundedImage!
    var imagePicker =  UIImagePickerController()
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var loginSignUpBtn: UIButton!
    
    var signUpViewShowing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        PFUser.current()?.image.getDataInBackground(block: { (imageData, error) in
            if let imageData = imageData{
                self.userImage.image = UIImage(data: imageData)
            } else if let error = error{
                print(error.localizedDescription)
            }
        })
        
        if PFAnonymousUtils.isLinked(with: PFUser.current()) {
            self.logoutBtn.isHidden = true
            signUpViewShowing = true
            performSegue(withIdentifier: "ToLoginSignUp", sender: self)
        } else{
            self.logoutBtn.isHidden = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFAnonymousUtils.isLinked(with: PFUser.current()) && !signUpViewShowing {
            performSegue(withIdentifier: "ToLoginSignUp", sender: self)
        }
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        userImage.image = (info[.editedImage] as! UIImage)
        PFUser.current()?.image = Utilities.imageToPFFileObject(image: userImage.image!, imageName: "userImage")
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                print("userImage updated 😉")
            }
        })
        dismiss(animated: true, completion: nil)
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
