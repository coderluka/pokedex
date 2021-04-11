//
//  LoginViewController.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 01.03.21.
//

import UIKit
import FirebaseAuth

class LoginViewController : UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var mailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    
    private var handleLogin : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTestIdentifiers()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // attach login listener
    override func viewWillAppear(_ animated: Bool) {
        handleLogin = Auth.auth().addStateDidChangeListener{ (auth, user) in
            print("[ debug ] start \(user?.email)")
        }
    }
    
    // detach login listener
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handleLogin!)
    }
    
    @IBAction func emailInputTxt(_ sender: UITextField) {
        
    }
    
    @IBAction func passInputTxt(_ sender: UITextField) {
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if mailTxt.text == "" || passTxt.text == "" {
            popUpError(title: "Login Error", msg: "Fields are left empty!", action: "Try Again")
            return
        }
            
        // sign in existing user
        Auth.auth().signIn(withEmail: mailTxt.text!, password: passTxt.text!, completion: { authResult, error in
            guard let signedInUser = authResult?.user, error == nil else {
                let signInError = error as! NSError
                
                if signInError.code == AuthErrorCode.wrongPassword.rawValue {
                    self.popUpError(title: "Login Error", msg: "Wrong password!", action: "Try Again")
                    return
                }
                
                // register new user if user was not found
                Auth.auth().createUser(withEmail: self.mailTxt.text!, password: self.passTxt.text!, completion: { authResult, err in
                    guard let newUser = authResult?.user, err == nil else {
                        let registerError = err as! NSError
                              switch registerError.code {
                              case AuthErrorCode.invalidEmail.rawValue:
                                self.popUpError(title: "Registration Error", msg: "Email address is invalid!", action: "Try Again")
                              case AuthErrorCode.weakPassword.rawValue:
                                self.popUpError(title: "Registration Error", msg: "Password must have at least 6 characters!", action: "Try Again")
                              default:
                                self.popUpError(title: "Registration Error", msg: "Something went wrong!", action: "Try Again")
                              }
                        return
                      }
                    print("[ debug ] new user \(newUser.email)")
                    
                    // new user registered
                    self.performSegue(withIdentifier: "toHome", sender: self)
                })
                return
            }
            print("[ debug ] signed in user \(authResult?.user.email)")
            
            // user registered ... can be used now
            self.performSegue(withIdentifier: "toHome", sender: self)
        })
    }
    
    func popUpError(title: String, msg: String, action: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: action, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK:- TextField Delegate
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK:- XCTUITest accessibility identifiers
extension LoginViewController {
    func setTestIdentifiers() {
        mailTxt.accessibilityIdentifier = "mail"
        passTxt.accessibilityIdentifier = "password"
        loginBtn.accessibilityIdentifier = "login"
    }
}
