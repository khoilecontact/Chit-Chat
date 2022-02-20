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
    var webView = WKWebView()
    // Github OAuth
    var provider = OAuthProvider(providerID: "github.com")
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: 320, height: 800)
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let appNameField: UILabel = {
        let appNameField = UILabel()
        appNameField.text = "Chit Chat"
        appNameField.textColor = Appearance.tint
        appNameField.font = UIFont.boldSystemFont(ofSize: 32.0)
        appNameField.textAlignment = .center
        return appNameField
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // Continue to next field
        field.returnKeyType = .continue
        field.backgroundColor = UIColor.systemBackground
        field.layer.borderWidth = 0
        field.placeholder = "Email..."
        field.textColor = Appearance.tint
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.backgroundColor = .systemBackground
        field.layer.borderWidth = 0
        field.placeholder = "Password..."
        field.textColor = Appearance.tint
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    private let forgotPasswordLabel: UILabel = {
        let forgotPasswordLabel = UILabel()
        forgotPasswordLabel.text = "Forgot password?"
        forgotPasswordLabel.textColor = Appearance.tint
        forgotPasswordLabel.font = .systemFont(ofSize: 15)
        forgotPasswordLabel.textAlignment = .right
        
        return forgotPasswordLabel
    }()
    
    private let forgotPasswordButton: UIButton = {
        let forgotPasswordButton = UIButton()
        forgotPasswordButton.setTitle("Reset password", for: .normal)
        forgotPasswordButton.backgroundColor = .systemBackground
        forgotPasswordButton.layer.borderWidth = 0
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 15)
        forgotPasswordButton.setTitleColor(.blue, for: .normal)
        return forgotPasswordButton
    }()
    
//    private let FBloginButton: FBLoginButton = {
//        let button = FBLoginButton()
//        button.permissions = ["email", "public_profile"]
//        button.layer.cornerRadius = 12
//        return button
//    }()
//
//    private let googleSignInButton = GIDSignInButton()
    
    private let googleSignInButton: UIButton = {
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                config.title = "Continue with Google"
                config.image = resizeImage(image: UIImage(named: "GoogleIcon")!, targetSize: CGSize(width: 30, height: 30))
                config.imagePadding = 60
                config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 30)
                config.baseBackgroundColor = UIColor.white
                config.baseForegroundColor = UIColor.black
                
                let button = UIButton(configuration: config, primaryAction: nil)
                button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
                button.layer.cornerRadius = 5
                button.layer.masksToBounds = true
                
                button.setTitleColor(UIColor.black, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                
                // action
                button.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
                
                // Add shadow
                button.layer.shadowColor = UIColor.gray.cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 3)
                button.layer.masksToBounds = false
                button.layer.shadowOpacity = 1
                button.layer.shadowRadius = 1
                
                return button
            } else {
                let button = UIButton()
                // action
                button.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
                //
                
                button.setTitle("Continue with Google", for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .white
                button.tintColor = .white
                button.layer.cornerRadius = 5
                button.layer.masksToBounds = true
                // Google icon
                let icon = resizeImage(image: UIImage(named: "GoogleIcon")!, targetSize: CGSize(width: 30, height: 30))
                button.setImage(icon, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
                //
                button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
                return button
            }
        }()
        
        private let FBloginButton: FBLoginButton = {
            let button = FBLoginButton()
            button.permissions = ["email", "public_profile"]
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            button.titleLabel?.textAlignment = .center
            
            // Add shadow
            button.layer.shadowColor = UIColor.gray.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
            button.layer.masksToBounds = false
            button.layer.shadowOpacity = 1
            button.layer.shadowRadius = 1
            
            return button
        }()
    
    private let githubSignInButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Log in with GitHub"
        config.image = resizeImage(image: UIImage(named: "GitHubLogo")!, targetSize: CGSize(width: 30, height: 30))
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 30)
        config.imagePadding = 60
        config.baseBackgroundColor = UIColor.gray
        config.baseForegroundColor = UIColor.white
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.layer.borderWidth = 0
        button.titleLabel?.font = .systemFont(ofSize: 15)
        
        button.imageView?.contentMode = .left
        button.layer.cornerRadius = 12
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        
        loginObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        view.backgroundColor = .systemBackground
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        githubSignInButton.addTarget(self, action: #selector(didTapGitHub), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        FBloginButton.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(appNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(forgotPasswordLabel)
        scrollView.addSubview(forgotPasswordButton)
        scrollView.addSubview(FBloginButton)
        scrollView.addSubview(googleSignInButton)
        scrollView.addSubview(githubSignInButton)
        scrollView.addSubview(registerButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: size, y: 20, width: size, height: size)
        imageView.backgroundColor = .systemBackground
        
        appNameField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width - 60, height: 52)
        
        emailField.frame = CGRect(x: 30, y: appNameField.bottom + 20, width: scrollView.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 30 , width: scrollView.width - 60, height: 52)
        
        loginButton.frame = CGRect(x: scrollView.width / 3.5, y: passwordField.bottom + 30 , width: scrollView.width - 220, height: 52)
        
        forgotPasswordLabel.frame = CGRect(x: 50, y: loginButton.bottom + 15 , width: 140, height: 20)
        
        forgotPasswordButton.frame = CGRect(x: forgotPasswordLabel.right + 3, y: loginButton.bottom + 15, width: 110, height: 20)
        
        FBloginButton.frame = CGRect(x: 30, y: forgotPasswordLabel.bottom + 20 , width: scrollView.width - 60, height: 52)
        
        googleSignInButton.frame = CGRect(x: 30, y: FBloginButton.bottom + 20 , width: scrollView.width - 60, height: 52)
        
        githubSignInButton.frame = CGRect(x: 30, y: googleSignInButton.bottom + 20 , width: scrollView.width - 60, height: 52)
        
        registerButton.frame = CGRect(x: scrollView.width / 4, y: githubSignInButton.bottom + 30, width: scrollView.width - 175, height: 52)
        
        // Add underline to textfields
        let bottomLine1 = CALayer()
        bottomLine1.backgroundColor = UIColor.black.cgColor
        bottomLine1.frame = CGRect(x: 5, y: emailField.frame.height - 2, width: emailField.frame.width - 1, height: 1)
        emailField.layer.addSublayer(bottomLine1)

        let bottomLine2 = CALayer()
        bottomLine2.backgroundColor = UIColor.black.cgColor
        bottomLine2.frame = CGRect(x: 5, y: passwordField.frame.height - 2, width: passwordField.frame.width - 1, height: 1)
        passwordField.layer.addSublayer(bottomLine2)
        
    }
    
    
    @objc func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        let isValid = validate()
        
        if !isValid {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { [weak self] authResult, error in
            
            DispatchQueue.main.async {
                self?.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to login user with email: \(String(describing: self?.emailField.text!))")
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            
            guard let email = self?.emailField.text else {
                return
            }
            
            // If email has not been verified
            if user.isEmailVerified == false {
                let alert = UIAlertController(title: "Email hasn't been verificated", message: "Please verify your email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self?.present(alert, animated: true)
                return
            } else {
                DatabaseManager.shared.userExists(with: email, completion: { exist in
                    if !exist {
                        DatabaseManager.shared.updateVerifiedUser(with: email, completion: { success in
                            if !success {
                                let alert = UIAlertController(title: "There has been an error", message: "Please verify your email", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                                self?.present(alert, animated: true)
                                return
                            }
                        })
                    }
                })
            }
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Error in getting user's info: \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            self?.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    @objc func googleSignInButtonTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                return
            }

            print("Did sign in with Google: \(String(describing: user))")

            guard let user = user else { return } 

            guard let email = user.profile?.email, let firstName = user.profile?.givenName, let lastName = user.profile?.familyName, let userId = user.userID else { return }

            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = User(id: userId, firstName: firstName, lastName: lastName, email: email, dob: "", isMale: true, province: "", district: "")
                    // Insert user to DB
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            //upload image
                            if ((user.profile?.hasImage) != nil) {
                                guard let url = user.profile?.imageURL(withDimension: 200) else {
                                    return
                                }

                                URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                    let fileName = chatUser.profilePictureFileName

                                    guard let data = data else { return }

                                    StorageManager.shared.uploadFrofilePicture(with: data, fileName: fileName, completion: { result in
                                        switch result {
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                            print(downloadUrl)
                                        case .failure(let error):
                                            print("Storage manager error: \(error)")
                                        }
                                    })
                                }).resume()
                            }

                        }
                    })
                }
            })

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)

            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Something is wrong when sign in Google")
                    return
                }

                print("Successfully log in with Google")
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            })
        }
    }
    
    @objc func didTapGitHub() {
        provider.customParameters = [
              "allow_signup": "false"
            ]
        provider.scopes = ["user:email"]

        provider.getCredentialWith(nil) { credential, error in
              if error != nil {
                // Handle error.
              }
            if credential != nil {
                FirebaseAuth.Auth.auth().signIn(with: credential!) { authResult, error in
                    if error != nil, authResult != nil {
                        return
                    }
                    
                    guard let user = authResult?.user else {
                        return
                    }
                    // User is signed in.
                    print("Did sign in with Google: \(String(describing: user))")
                    // IdP data available in authResult.additionalUserInfo.profile.
                    
                    let uid = user.uid
                    guard let email = user.email, let name = user.displayName else { return }
                    
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set("\(name)", forKey: "name")
                    
                    DatabaseManager.shared.userExists(with: email, completion: { exist in
                        if !exist {
                            let chatUser = User(id: uid, firstName: name, lastName: "", email: email, dob: "", isMale: true, province: "", district: "")
                            // Insert user to DB
                            DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                                if success {
                                    //upload image
                                    if ((user.photoURL) != nil) {
                                        guard let url = user.photoURL else {
                                            return
                                        }
                                        
                                        URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                            let fileName = chatUser.profilePictureFileName
                                            
                                            guard let data = data else { return }
                                            
                                            StorageManager.shared.uploadFrofilePicture(with: data, fileName: fileName, completion: { result in
                                                switch result {
                                                case .success(let downloadUrl):
                                                    UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                                    print(downloadUrl)
                                                case .failure(let error):
                                                    print("Storage manager error: \(error)")
                                                }
                                            })
                                        }).resume()
                                    }
                                    
                                }
                            })
                        }
                    })
                    
                    
                    guard (authResult!.credential as? OAuthCredential) != nil else { return }
                    // GitHub OAuth access token can also be retrieved by:
                    // oauthCredential.accessToken
                    // GitHub OAuth ID token can be retrieved by calling:
                    // oauthCredential.idToken
                    
                    print("Successfully log in with Github")
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                }
            }
        }
        
        
    }
    
    @objc func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func refreshAction() {
        self.webView.reload()
    }
    
    func validate() -> Bool {
        guard let email = emailField.text, !email.isEmpty else {
            alertMessage = "Please enter an Email"
            return false
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            alertMessage = "Please enter a Password"
            return false
        }
        
        if !email.contains("@") {
            alertMessage = "Please input a valid email"
            return false
        }
        
        if password.count < 6 {
            alertMessage = "Password must contains at least 6 letters"
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //nothing
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // Unwraph token from Facebook
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with Facebook")
            return
        }

        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "id, email, first_name, last_name, picture.type(large), birthday, gender"], tokenString: token, version: nil, httpMethod: .get)

        facebookRequest.start(completion: { connection, result, error in
            guard let result = result as? [String: Any ], error == nil else {
                print("Failed to make Facebook Graph request")
                return
            }
//
//            //Debug
//            print(result)
//                        return
            
            // Waiting for FB authorization of birthday and gender field
            guard let email = result["email"] as? String, let id = result["id"] as? String,
                  let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any], let pictureUrl = data["url"] as? String
//                  ,let dob = result["birthday"] as? String,
//                  let gender = result["gender"] as? String
            else {
                print("Failed to get info from Facebook")
                return
            }
            
//            var isMale = true
//
//            switch gender {
//            case "female":
//                isMale = false
//                break
//
//            default:
//                isMale = true
//                break
//            }

            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

            DatabaseManager.shared.userExists(with: email, completion: { exists in
                let chatUser = User(id: id, firstName: firstName, lastName: lastName, email: email, dob: "", isMale: true, province: "", district: "")
                if !exists {
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { [weak self] success in
                        if success {
                            //upload image
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }

                            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in

                                guard data != nil else { return }
                                guard error == nil else { return }
                                
                                DispatchQueue.main.async {
                                    guard let image = self?.imageView.image, let _ = image.pngData() else {
                                        return
                                    }
                                }

                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadFrofilePicture(with: data!, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })

                            }).resume()

                        }
                    })
                } else {
                    let alert = UIAlertController(title: "User existed", message: "Email of user existed! Please try another account", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self.present(alert, animated: true)
                    return
                }
            })

            //Create user in Firebase database - not in Authentication cuz it's already created in there
            let credential = FacebookAuthProvider.credential(withAccessToken: token)

            //Log in Firebase using Facebook
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard authResult != nil, error == nil else {
                    print("Facebook log in fail, MFA maybe needed")
                    print(error ?? "Not error")
                    return
                }

                print("Sucessfully log in")
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
        })

    }
    
    
}
