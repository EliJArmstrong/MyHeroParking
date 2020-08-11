//
//  GradientView.swift
//  Smack
//
//  Created by Eli Armstrong on 8/24/18.
//  Copyright © 2018 Eli Armstrong. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    // In swift you can have an action when a variable is set by using the fuction brackets.
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.790450871, green: 0, blue: 0.5167049766, alpha: 1){
        // This func will be called when the var above is being set.
        didSet {
            // This tells the view to update when the IU color is changed.
            self.setNeedsLayout()
        }
    }
    
    // In swift you can have an action when a variable is set by using the fuction brackets.
    @IBInspectable var buttomColor: UIColor = #colorLiteral(red: 0.8588185906, green: 0.7039487362, blue: 0, alpha: 1){
        // This func will be called when the var above is being set.
        didSet {
            // This tells the view to update when the IU color is changed.
            self.setNeedsLayout()
        }
    }
    
    
    // This fuction is called when "self.setNeedsLayout()" is called in the topColor/buttomColor vars are changed.
    override func layoutSubviews() {
        
        let gradientLayer = CAGradientLayer()
        
        // The colors the gradient will blend into from left to right.
        gradientLayer.colors = [topColor.cgColor, buttomColor.cgColor];
        
        // This will make the start point to the top left corner.
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        // This will make the end point the bottom right corner.
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Creates the frame size for the same size for the view the gradient is in.
        gradientLayer.frame = self.bounds
        
        // This will insert The gradientLayer this was created above at the top of the view that's what the zeros for.
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    
}
