//
//  LoginViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 26/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    var alertMessage = ""
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

   

}
