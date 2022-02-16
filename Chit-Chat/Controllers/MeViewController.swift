//
//  MeViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/02/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

class MeViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var personalInfoButton: UIButton!
    @IBOutlet var friendListButton: UIButton!
    @IBOutlet var darkModeButton: UIButton!
    @IBOutlet var logOutButton: UIButton!
    
    var user: User?! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        
        // Get data of user
        getUserInfo(completion: { [weak self] user in
            if user != nil {
                self?.user = user
                
                // Initilize data for layout
                self?.initLayout()
            }
        })
        
    }
    
    /// Get user's data from Firebase Database
    private func getUserInfo(completion: @escaping (User?) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
            switch result {
            case .success(let data):
                guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                      let lastName = userData["last_name"] as? String,
                      let id = userData["id"] as? String,
                      let isMale = userData["is_male"] as? Bool else {
                          completion(nil)
                          return
                      }
                
                let userResult = User(id: id, firstName: firstName, lastName: lastName, email: email, dob: "", isMale: isMale)
                completion(userResult)
                
                break
            case .failure(let error):
                print("Error in getting user info: \(error)")
                completion(nil)
                break
            }
        })
    }
    
    private func initLayout() {
        guard let user = self.user as? User else { return }
        
        // Set profile picture
        guard let email = UserDefaults.standard.value(forKey: "email") else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to download image URL: \(error)")
                self?.imageView.image = UIImage(systemName: "person.circle")
                break
            
            case .success(let url):
                self?.imageView.sd_setImage(with: url, completed: nil)
            }
        })
        
        imageView.tintColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        
        nameLabel.text = user.firstName + " " + user.lastName
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        
        bioLabel.text = (user.bio == "") ? "This is your bio" : user.bio
        bioLabel.textColor = UIColor.black
        bioLabel.textAlignment = .center
        bioLabel.layer.borderWidth = 1
        bioLabel.layer.borderColor = UIColor.black.cgColor
        bioLabel.layer.cornerRadius = 12
        bioLabel.layer.backgroundColor = UIColor.systemBackground.cgColor
        
        var config = UIButton.Configuration.filled()
        config.imagePadding = 20
        config.baseBackgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        config.baseForegroundColor = .black
        
        personalInfoButton.configuration = config
        personalInfoButton.setTitleColor(.black, for: .normal)
        personalInfoButton.setTitle("Personal Information", for: .normal)
        let image = UIImage(systemName: "person.crop.square")
        
        personalInfoButton.setImage(UIImage(systemName: "person.crop.square"), for: .normal)
        personalInfoButton.layer.cornerRadius = 12
        personalInfoButton.layer.borderWidth = 1
        personalInfoButton.layer.masksToBounds = false
        personalInfoButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        personalInfoButton.layer.shadowOpacity = 0.3
        personalInfoButton.layer.shadowRadius = 1
        
        friendListButton.configuration = config
        friendListButton.setTitleColor(.black, for: .normal)
        friendListButton.setTitle("Friend List", for: .normal)
        friendListButton.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        friendListButton.layer.cornerRadius = 12
        friendListButton.layer.borderWidth = 1
        friendListButton.layer.masksToBounds = false
        friendListButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        friendListButton.layer.shadowOpacity = 0.3
        friendListButton.layer.shadowRadius = 1
        
        darkModeButton.configuration = config
        darkModeButton.setTitleColor(.black, for: .normal)
        darkModeButton.setTitle("Dark Mode", for: .normal)
        darkModeButton.setImage(UIImage(systemName: "moon.fill"), for: .normal)
        darkModeButton.layer.cornerRadius = 12
        darkModeButton.layer.borderWidth = 1
        darkModeButton.layer.masksToBounds = false
        darkModeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        darkModeButton.layer.shadowOpacity = 0.3
        darkModeButton.layer.shadowRadius = 1
        
        var logOutConfig = UIButton.Configuration.filled()
        logOutConfig.imagePadding = 20
        logOutConfig.baseBackgroundColor = .init(red: CGFloat(255) / 255.0, green: CGFloat(113) / 255.0, blue: CGFloat(104) / 255.0, alpha: 1.0)
        logOutConfig.baseForegroundColor = .white
        
        logOutButton.configuration = logOutConfig
        logOutButton.setTitleColor(UIColor.white, for: .normal)
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right")?.sd_rotatedImage(withAngle: .pi, fitSize: false)?.withTintColor(.white), for: .normal)
        logOutButton.layer.cornerRadius = 12
        logOutButton.layer.borderWidth = 1
        logOutButton.layer.masksToBounds = false
        logOutButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        logOutButton.layer.shadowOpacity = 0.3
        logOutButton.layer.shadowRadius = 1
    }
    
    @objc func logOutButtonTapped() {

            let actionAlert = UIAlertController(title: "Do you wanna logout?", message: "Choose Log Out to Logout", preferredStyle: .alert)
            
            actionAlert.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
                // Log out Facebook
                FBSDKLoginKit.LoginManager().logOut()
                
                //Log out Google
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let vc = LoginViewController()
                    // Create a navigation controller
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen

                    self?.present(nav, animated: true)
                } catch {
                    print("Error in signing out")
                }
                
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(actionAlert, animated: true)
    }
}

