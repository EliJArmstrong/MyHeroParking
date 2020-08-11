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
}

