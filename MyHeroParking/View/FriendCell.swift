//
//  FriendCell.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/12/20.
//  Copyright © 2020 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class FriendCell: UICollectionViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    
    func setData(friendData: PFUser){
        userImg.image = #imageLiteral(resourceName: "friends_icon")
        friendData.image.getDataInBackground { (imageData, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let imageData = imageData {
                self.userImg.image = UIImage(data: imageData)
            } else{
                print("Something crazy happen if we made it here. 🤪")
            }
        }
    }
    
}
