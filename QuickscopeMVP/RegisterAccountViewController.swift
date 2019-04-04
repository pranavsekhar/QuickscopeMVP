//
//  RegisterAccountViewController.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/3/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == self.passwordTextField {
            textField.resignFirstResponder()
            signUpButton.sendActions(for: .touchUpInside)
        }
        return true
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        //Validate required fields are not empty:
        if (emailTextField.text?.isEmpty)! ||
            (passwordTextField.text?.isEmpty)!
        {
            
            myActivityIndicator.stopAnimating()
            myActivityIndicator.removeFromSuperview()
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error == nil {
                print("SUCCESSFUL SIGN UP")
                
//                let TutorialView = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController")
//                self.present(TutorialView!, animated: true, completion: nil)
                
            } else {
                myActivityIndicator.stopAnimating()
                myActivityIndicator.removeFromSuperview()
                
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

}
