//
//  SignInLogInVC.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/21/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class SignInLogInVC: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func LoginBtnaPressed(_ sender: Any) {
        if emailField.text!.contains("@") && emailField.text!.contains("."){
            loginWithEmail()
        } else{
            loginWithUsername()
        }
    }
    
    
    func loginWithEmail(){
        let queryUser = PFUser.query()
        queryUser?.whereKey("email", equalTo: emailField.text ?? "noemail")
        queryUser?.getFirstObjectInBackground(block: { (user, error) in
            if let user = user{
               let pfuser = user as! PFUser
                PFUser.logInWithUsername(inBackground: pfuser.username!, password: self.passwordField.text!) { (PFUser, error) in
                    if let error = error {
                        self.present(Utilities.createAlert(titleOfAleart: "Login Error", message: error.localizedDescription), animated: true, completion: nil)
                    } else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else if let error = error {
                self.present(Utilities.createAlert(titleOfAleart: "Login Error", message: error.localizedDescription), animated: true, completion: nil)
            }
        })
    }
    
    
    func loginWithUsername(){
        PFUser.logInWithUsername(inBackground: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
            if let error = error {
                self.present(Utilities.createAlert(titleOfAleart: "Login Error", message: error.localizedDescription), animated: true, completion: nil)
            } else{
                self.dismiss(animated: true, completion: nil)
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

    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
