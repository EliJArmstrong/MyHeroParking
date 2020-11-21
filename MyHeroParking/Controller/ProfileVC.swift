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
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var karmaLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var loginSignUpBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
    left: 20.0,
    bottom: 50.0,
    right: 20.0)

    var friendsList: [PFUser]?
    
    var signUpViewShowing = false
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFriendsData()
        if PFAnonymousUtils.isLinked(with: PFUser.current()) {
            self.logoutBtn.isHidden = true
            self.loginSignUpBtn.isHidden = false
            userNameLbl.text = "Anonymous User"
            karmaLbl.text = "Login to gain Karma"
            userImage.image = #imageLiteral(resourceName: "add_photo_btn")
            signUpViewShowing = true
            //performSegue(withIdentifier: "ToLoginSignUp", sender: self)
        } else{
            self.logoutBtn.isHidden = false
            self.loginSignUpBtn.isHidden = true
            self.karmaLbl.text = "Karma: \(PFUser.current()?.experiencePoints ?? 0)"
            self.userNameLbl.text = PFUser.current()?.username
            PFUser.current()?.image.getDataInBackground(block: { (imageData, error) in
                if let imageData = imageData{
                    self.userImage.image = UIImage(data: imageData)
                } else if let error = error{
                    print(error.localizedDescription)
                }
                //self.collectionView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imagePicker.delegate = self
        // I set the delegate and data source in the storyboard
        // collectionView.delegate = self
        // collectionView.dataSource = self
        
        checkForAnonymousUser()
        fetchFriendsData()
        // Do any additional setup after loading the view.
    }
    
    func checkForAnonymousUser() {
        if PFAnonymousUtils.isLinked(with: PFUser.current()) {
            self.logoutBtn.isHidden = true
            self.loginSignUpBtn.isHidden = false
            userNameLbl.text = "Anonymous User"
            karmaLbl.text = "Login to gain Karma"
            signUpViewShowing = true
            performSegue(withIdentifier: "ToLoginSignUp", sender: self)
        } else{
            self.logoutBtn.isHidden = false
            self.loginSignUpBtn.isHidden = true
            self.karmaLbl.text = "Karma: \(PFUser.current()?.experiencePoints ?? 0)"
            self.userNameLbl.text = PFUser.current()?.username
            PFUser.current()?.image.getDataInBackground(block: { (imageData, error) in
                if let imageData = imageData{
                    self.userImage.image = UIImage(data: imageData)
                } else if let error = error{
                    print(error.localizedDescription)
                }
                //self.collectionView.reloadData()
            })
        }
    }
    
    func fetchFriendsData(){
        PFUser.fetchAllIfNeeded(inBackground: PFUser.current()?.friends) { (users, error) in
            if let users = users as? [PFUser] {
                self.friendsList = users
                self.collectionView.reloadData()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if let error = error{
                self.present(Utilities.createAlert(titleOfAlert: "Logout error", message: error.localizedDescription), animated: true, completion: nil)
            } else {
                PFAnonymousUtils.logIn { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.viewWillAppear(true)
                    }
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if PFAnonymousUtils.isLinked(with: PFUser.current()) && !signUpViewShowing {
            performSegue(withIdentifier: "ToLoginSignUp", sender: self)
        }
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        if PFAnonymousUtils.isLinked(with: PFUser.current()){
            let alert = UIAlertController(title: "Sign in required", message: "Login to add an image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true) {
                print("alert happen")
            }
            
        } else{
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallery()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
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
    
    func openGallery()
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToLoginSignUp"{
            
        } else if segue.identifier == "toFriendVC" {
            let friendVC = segue.destination as! FriendsVC
            let cell = sender as! UICollectionViewCell
            if let indexPath = self.collectionView.indexPath(for: cell){
                friendVC.friend = self.friendsList![indexPath.item]
            }
        } else {
            print("No conditional for \(segue.identifier ?? "segue (no identifier given)")")
        }
    }
    

}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friendsList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
        cell.userImg.image = #imageLiteral(resourceName: "friends_icon")
        cell.setData(friendData: (self.friendsList![indexPath.row]))
        // Configure the cell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 1
        switch kind {
        // 2
        case UICollectionView.elementKindSectionHeader:
          // 3
          guard
            let headerView = collectionView.dequeueReusableSupplementaryView(
              ofKind: kind,
              withReuseIdentifier: "collectionHeader",
              for: indexPath) as? FriendHeader
            else {
              fatalError("Invalid view type")
          }
          if PFUser.current()?.friends.count == 0{
            headerView.FriendsListLbl.text = "Following List"
            headerView.numberOFFriendsLbl.text = "You are not following anyone"
          } else{
            headerView.FriendsListLbl.text = "Following List"
            headerView.numberOFFriendsLbl.text = "\(PFUser.current()?.friends.count ?? 0)"
          }
          
          return headerView
        default:
          // 4
          assert(false, "Invalid element type")
        }
    }
    
}

extension ProfileVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      //2
      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      
      return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
}

