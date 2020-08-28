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
    
    
    override func viewWillAppear(_ animated: Bool) {
        if !PFAnonymousUtils.isLinked(with: PFUser.current()) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
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
        let email = emailField.text!.lowercased()
        queryUser?.whereKey("email", equalTo: email)
        queryUser?.getFirstObjectInBackground(block: { (user, error) in
            if let user = user{
               let pfuser = user as! PFUser
                PFUser.logInWithUsername(inBackground: pfuser.username!, password: self.passwordField.text!) { (PFUser, error) in
                    if let error = error {
                        self.present(Utilities.createAlert(titleOfAleart: "Login Error", message: "Could not find the email linked to an account"), animated: true, completion: nil)
                        print(error.localizedDescription)
                    } else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else if let error = error {
                self.present(Utilities.createAlert(titleOfAleart: "Login Error", message: error.localizedDescription), animated: true, completion: nil)
            }
        })
    }
    
    
    func loginWithUsername(){
        let email = self.emailField.text!.lowercased()
        PFUser.logInWithUsername(inBackground: email, password: self.passwordField.text!) { (user, error) in
            if let error = error {
                self.present(Utilities.createAlert(titleOfAleart: "Login Error", message: error.localizedDescription), animated: true, completion: nil)
            } else{
                self.navigationController?.popViewController(animated: true)
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
       self.navigationController?.popViewController(animated: true)
    }
}
