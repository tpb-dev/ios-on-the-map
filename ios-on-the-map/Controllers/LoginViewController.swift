//
//  LoginViewController.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/8/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

extension UIViewController {
    
    func showErrorAlert(message: String, dismissButtonTitle: String = "OK") {
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: dismissButtonTitle, style: .default) { (action: UIAlertAction!) in
            controller.dismiss(animated: true, completion: nil)
        })
        
        self.present(controller, animated: true, completion: nil)
    }
}


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let udacityLogin = UdacityClient()
    
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTextAndImageAndButtons()
    }
    
    func setDefaultTextAndImageAndButtons() {
        setupTextFields(txtFld: usernameField, txt: "Username", secure: false)
        setupTextFields(txtFld: passwordField, txt: "Password", secure: true)
        loginView.backgroundColor = UIColor(red: 234, green: 106, blue: 32)
        setupButtons(button: signInButton)
        setupButtons(button: signUpButton)
    }
    
    func setupButtons(button: UIButton) {
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
    }
    
    func setupTextFields(txtFld: UITextField, txt: String, secure: Bool) {
        txtFld.borderStyle = .bezel
        txtFld.textAlignment = .left
        txtFld.placeholder = txt
        txtFld.isSecureTextEntry = secure
        txtFld.backgroundColor = UIColor.white
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    @IBAction func clickSignUp(_ sender: Any) {
        print("sign up button clicked")
        UIApplication.shared.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickSignIn(_ sender: Any) {
        print("sign in button clicked")
        udacityLogin.login(username: usernameField.text, password: passwordField.text) { (resp, error) -> Void in
            let mainQueue = DispatchQueue.main
            mainQueue.async(execute: {
                
                    guard error == nil else {
                        self.showErrorAlert(message: error!, dismissButtonTitle: "OK")
                        return
                    }
                
                    let storyboard = self.storyboard
                    let tabBarController = storyboard?.instantiateViewController(withIdentifier: "tabBarController")
                
                    self.present(tabBarController!, animated: true, completion: nil)
                })
            }

    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if passwordField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
}
