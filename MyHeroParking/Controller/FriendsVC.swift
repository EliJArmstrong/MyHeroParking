//
//  FriendsVC.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/15/20.
//  Copyright © 2020 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class FriendsVC: UIViewController {

    @IBOutlet weak var karmaBtn: UIButton!
    @IBOutlet weak var karmaLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    
    
    var friend: PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
// self.bar
        setupButtons(buttons: [karmaBtn, followBtn])
        karmaLbl.text = "\(friend.experincePoints)"
        usernameLbl.text = friend.username
        if friendInList(){
            followBtn.setTitle("Unfollow", for: .normal)
        }
        self.userImage.image = #imageLiteral(resourceName: "friends_icon")
        friend.image.getDataInBackground { (imageData, error) in
            if let imageData = imageData{
                self.userImage.image = UIImage(data: imageData)
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func setupButtons(buttons: [UIButton]){
        for button in buttons{
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // it's black
        }
    }
    
    @IBAction func touchedFollowBtn(_ sender: Any) {
        if followBtn.titleLabel?.text == "Follow"{
            PFUser.current()?.friends.append(friend)
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else{
                    print("🤩 Friend saved 🤩")
                }
            })
             followBtn.setTitle("Unfollow", for: .normal)
        } else {
             followBtn.setTitle("Follow", for: .normal)
            removeFriend(friendToBeRemoved: self.friend)
        }
        
    }
    
    @IBAction func touchedGiveKarmaBtn(_ sender: Any) {
        self.friend.incrementKey("experincePoints")
        self.friend.saveInBackground { (sucess, error) in
            if let error = error {
                print("Karma Failed")
                print(error.localizedDescription)
                self.present(Utilities.createAlert(titleOfAleart: "Anonymous user error", message: error.localizedDescription), animated: true, completion: nil)
            } else {
                print("Karma increased")
                self.karmaLbl.text = "\(Int(self.karmaLbl.text ?? "0")! + 1)"
            }
        }
        self.karmaBtn.isEnabled = false
    }
    
    func friendInList() -> Bool{
        for friend in PFUser.current()!.friends{
            if friend.objectId == self.friend.objectId{
                return true
            }
        }
        return false
    }
    
    
    func removeFriend(friendToBeRemoved: PFUser) {
        for (index, friend) in PFUser.current()!.friends.enumerated() {
            if friend.objectId == friendToBeRemoved.objectId {
                PFUser.current()?.friends.remove(at: index)
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if let error = error{
                        print(error.localizedDescription)
                    } else {
                        print("😎 Friend removed 😎")
                    }
                })
                return
            }
        }
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
