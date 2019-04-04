//
//  LoginViewController.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/2/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
            signInButton.sendActions(for: .touchUpInside)
        }
        return true
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            myActivityIndicator.stopAnimating()
            myActivityIndicator.removeFromSuperview()
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                if error == nil {
                    print("SUCCESSFUL LOGIN")
                    //let HomeTabControllerView = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabController")
                    //self.present(HomeTabControllerView!, animated: true, completion: nil)
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
}
