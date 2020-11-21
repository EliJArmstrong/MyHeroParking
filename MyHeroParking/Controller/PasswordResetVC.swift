//
//  PasswordResetVC.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/23/20.
//  Copyright © 2020 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class PasswordResetVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func returnKeyPressed(_ sender: Any) {
        if Utilities.isValidEmail(emailField.text!){
            PFUser.requestPasswordResetForEmail(inBackground: emailField.text!) { (success, error) in
                if let error = error {
                    self.present(Utilities.createAlert(titleOfAlert: "Error", message: error.localizedDescription), animated: true, completion: nil)
                } else if success {
                    let alert = UIAlertController(title: "Password Reset", message: "If email is in our records an email will be sent to you with a reset password link", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
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
