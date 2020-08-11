//
//  RoundedImage.swift
//  NotSoAwesomeGram
//
//  Created by Eli Armstrong on 3/4/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     *///
    override func awakeFromNib() {
        setUpView()
    }
    
    @IBInspectable var cornerRadius: CGFloat = 3.0{
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
    }
    
    func setUpView(){
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setUpView()
    }
    
}
