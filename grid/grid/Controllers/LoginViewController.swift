//
//  LoginViewController.swift
//  grid
//
//  Created by Konrad Gnat on 1/23/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet weak var confirmPassowrdRef: UITextField!
    @IBOutlet weak var loginButtonRef: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldLoginEmail.returnKeyType = UIReturnKeyType.done
        textFieldLoginPassword.returnKeyType = UIReturnKeyType.done
        confirmPassowrdRef.isHidden = true
        
        Auth.auth().addStateDidChangeListener() { auth, user in
          if user != nil {
            self.textFieldLoginEmail.text = nil
            self.textFieldLoginPassword.text = nil
            self.dismiss(animated: true, completion: nil)
          }
        }
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func validateFields() -> Bool {
        var messages: [String] = []
        var isValid = true
        let isSignUp = !confirmPassowrdRef.isHidden
        let title = isSignUp ? "Sign up Failed" : "Log in Failed"
        if textFieldLoginEmail.text == nil {
            isValid = false
            messages.append("Email field must not be empty")
        }
        if textFieldLoginPassword.text == nil {
            isValid = false
            messages.append("Password field must not be empty")
        }
        if !isValidEmail(textFieldLoginEmail.text!) {
            isValid = false
            messages.append("Email must be valid")
        }
        if textFieldLoginPassword.text!.count <= 6 {
            isValid = false
            messages.append("Password must be longer than 6 characters")
        }
        if isSignUp && textFieldLoginPassword.text != confirmPassowrdRef.text {
            isValid = false
            messages.append("Passwords don't match")
        }
        
        if !isValid {
            let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
            let alert = UIAlertController(
                title: title,
                message: errorMessage,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alert, animated: true, completion: nil)
        }
        
        return isValid
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        if !validateFields() {
            return
        }
        let email = textFieldLoginEmail.text!
        let password = textFieldLoginPassword.text!

        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(
                    title: "Sign in Failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alert, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backDidTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        if !confirmPassowrdRef.isHidden {
            signUp()
        } else {
            confirmPassowrdRef.isHidden = false
        }
    }
    func showPasswordsDontMatchAlert() {
            let alert = UIAlertController(
                title: "Sign Up Failed",
                message: "Passwords don't match",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
    }
    @IBAction func didEndSignup(_ sender: UITextField) {
        signUp()
    }
    func signUp() {
        if !validateFields() {
            return
        }
        Auth.auth().createUser(
            withEmail: textFieldLoginEmail.text!,
            password: textFieldLoginPassword.text!
        ) { user, error in
            if error == nil {
                Auth.auth().signIn(
                    withEmail: self.textFieldLoginEmail.text!,
                    password: self.textFieldLoginPassword.text!
                )
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
}
