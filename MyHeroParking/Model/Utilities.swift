//
//  Utilities.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/21/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import Foundation
import Parse
import AlamofireImage

class Utilities{
    static func imageToPFFileObject(image: UIImage, imageName: String) -> PFFileObject {
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        return PFFileObject(name: "\(imageName).png", data: scaledImage.pngData()!)!
    }
    
    static func createAlert(titleOfAlert: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: titleOfAlert, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        return alert
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}


