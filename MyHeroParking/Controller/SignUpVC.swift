//
//  SignUpVC.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 8/22/20.
//  Copyright © 2020 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class SignUpVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpbuttonPressed(_ sender: Any) {
        //print("🥶 \(emailField.text?.lowercased()) 🥶")
        if Utilities.isValidEmail(emailField.text?.lowercased() ?? ""){
            
            PFUser.current()?.username = usernameField.text?.lowercased() ?? ""
            PFUser.current()?.password = passwordField.text ?? ""
            PFUser.current()?.email = emailField.text?.lowercased() ?? ""
            
            
            PFUser.current()?.signUpInBackground(block: { (success, error) in
                if let error = error {
                    self.present(Utilities.createAlert(titleOfAleart: "SignUp Error", message: error.localizedDescription), animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Email Sent", message: "An validation email was sent to \(self.emailField.text!)", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                        self.popNavView()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else{
            self.present(Utilities.createAlert(titleOfAleart: "SignUp Error", message: "Email invild"), animated: true, completion: nil)
        }
        
        
    }
    
    func popNavView(){
        self.navigationController?.popViewController(animated: true)
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
