//
//  ViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 30/12/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            // Create a navigation controller
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true)
        }
    }

}


