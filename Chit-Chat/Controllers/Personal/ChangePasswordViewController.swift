//
//  ResetPasswordViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 21/02/2022.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    var showingAlert = false
    var alertMessage = ""
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: 320, height: 800)
        return scrollView
    }()
    
    private let oldPasswordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.backgroundColor = .systemBackground
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Old Password"
        field.textColor = Appearance.tint
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let newPasswordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.backgroundColor = .systemBackground
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "New Password"
        field.textColor = Appearance.tint
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let reNewPasswordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.backgroundColor = .systemBackground
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Repeat New Password..."
        field.textColor = Appearance.tint
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.isSecureTextEntry = true
        
        return field
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.black, for: .normal)
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

        title = "Change Password"
        
        view.backgroundColor = .systemBackground
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(oldPasswordField)
        scrollView.addSubview(newPasswordField)
        scrollView.addSubview(reNewPasswordField)
        scrollView.addSubview(saveButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        oldPasswordField.frame = CGRect(x: 20, y: 30, width: scrollView.width - 60, height: 52)
        
        newPasswordField.frame = CGRect(x: 20, y: oldPasswordField.bottom + 30, width: scrollView.width - 60, height: 52)
        
        reNewPasswordField.frame = CGRect(x: 20, y: newPasswordField.bottom + 30, width: scrollView.width - 60, height: 52)
        
        saveButton.frame = CGRect(x: 30, y: reNewPasswordField.bottom + 40, width: scrollView.width - 60, height: 52)
    }
    
    @objc func saveButtonTapped() {
        let isValid = validate()
        
        if !isValid {
            alertUserLoginError()
        }
    }

    func validate() -> Bool {
        guard let oldPassword = oldPasswordField.text, !oldPassword.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter a Password"
            return false
        }
        
        guard let newPassword = newPasswordField.text, !newPassword.isEmpty else {
            showingAlert = true
            alertMessage = "Please enter a New Password"
            return false
        }
        
        guard let reNewPassword = reNewPasswordField.text, !reNewPassword.isEmpty else {
            showingAlert = true
            alertMessage = "Please repeat your Repeat New Password"
            return false
        }
        
        return true
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Opps!", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}
