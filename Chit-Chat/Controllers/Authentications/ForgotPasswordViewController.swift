//
//  ForgotPasswordViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 24/02/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ForgotPasswordViewController: UIViewController {
    var showingAlert = false
    var alertMessage = ""
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: 320, height: 800)
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.backgroundColor = .systemBackground
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Enter your email"
        field.textColor = Appearance.tint
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        return field
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset Password", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.titleLabel?.textAlignment = .center
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Forgot password"
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: nil)
        
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(sendButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        emailField.frame = CGRect(x: 20, y: 30, width: scrollView.width - 60, height: 52)
        
        sendButton.frame = CGRect(x: 30, y: emailField.bottom + 40, width: scrollView.width - 60, height: 52)
    }
    
    @objc func sendButtonTapped() {
        let isValid = validate()
        
        if !isValid {
            alertUser()
            return
        }
        
        spinner.show(in: view)
        
        guard let email = emailField.text else { return }
        
        DatabaseManager.shared.resetPassword(with: email, completion: { [weak self] success in
            if success {
                let alert = UIAlertController(title: "Sent!", message: "A reset password email has been sent to your email! Please check your mail", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self?.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Opps!", message: "Your email hasn't been registered or there has been an error! Please check your email and try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self?.present(alert, animated: true)
            }
        })
        
        DispatchQueue.main.async {
            self.spinner.dismiss(animated: true)
        }
    }
    
    func validate() -> Bool {
        guard let email = emailField.text, !email.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter your email"
            return false
        }
        
        return true
    }
    
    func alertUser() {
        let alert = UIAlertController(title: "Opps!", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }

}
