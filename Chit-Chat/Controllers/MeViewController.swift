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
    @IBOutlet var blackListButton: UIButton!
    
    var user: User?! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personalInfoButton.addTarget(self, action: #selector(personalInfoTapped), for: .touchUpInside)
        friendListButton.addTarget(self, action: #selector(friendListTapped), for: .touchUpInside)
        darkModeButton.addTarget(self, action: #selector(darkModeTapped), for: .touchUpInside)
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
    
    override func viewDidAppear(_ animated: Bool) {
        // Get data of user
        getUserInfo(completion: { [weak self] user in
            if user != nil {
                self?.user = user
                
                // Initilize data for layout
                self?.initLayout()
            }
        })
    }
    
    // Handle dark mode appearance
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        initLayout()
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
                      let isMale = userData["is_male"] as? Bool,
                      let dob = userData["dob"] as? String,
                      let province = userData["province"] as? String,
                      let district = userData["district"] as? String,
                      let bio = userData["bio"] as? String
                else {
                          completion(nil)
                          return
                      }
                
                let userResult = User(id: id, firstName: firstName, lastName: lastName, bio: bio, email: email, dob: dob, isMale: isMale, province: province, district: district)
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
                self?.imageView.image = UIImage(systemName: "person.circle")?.withTintColor(Appearance.tint)
                
                break
            
            case .success(let url):
                self?.imageView.sd_setImage(with: url, completed: nil)
            }
        })
        
        imageView.image?.withTintColor(Appearance.tint)
//        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.borderWidth = 0
        imageView.clipsToBounds = true
        
        nameLabel.text = user.firstName + " " + user.lastName
        nameLabel.textColor = Appearance.tint
        nameLabel.textAlignment = .center
        
        bioLabel.text = (user.bio == "") ? "This is your bio" : user.bio
        bioLabel.textColor = Appearance.tint
        bioLabel.textAlignment = .center
        bioLabel.layer.borderWidth = 1
        bioLabel.layer.borderColor = Appearance.tint.cgColor
        bioLabel.layer.cornerRadius = 12
        bioLabel.layer.backgroundColor = UIColor.systemBackground.cgColor
        
        personalInfoButton.layer.cornerRadius = 12
        personalInfoButton.layer.borderWidth = 1
        personalInfoButton.layer.masksToBounds = false
        personalInfoButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        personalInfoButton.layer.shadowOpacity = 0.3
        personalInfoButton.layer.shadowRadius = 1
        
        friendListButton.layer.cornerRadius = 12
        friendListButton.layer.borderWidth = 1
        friendListButton.layer.masksToBounds = false
        friendListButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        friendListButton.layer.shadowOpacity = 0.3
        friendListButton.layer.shadowRadius = 1
        
        darkModeButton.layer.cornerRadius = 12
        darkModeButton.layer.borderWidth = 1
        darkModeButton.layer.masksToBounds = false
        darkModeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        darkModeButton.layer.shadowOpacity = 0.3
        darkModeButton.layer.shadowRadius = 1
        
        blackListButton.layer.cornerRadius = 12
        blackListButton.layer.borderWidth = 1
        blackListButton.layer.masksToBounds = false
        blackListButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        blackListButton.layer.shadowOpacity = 0.3
        blackListButton.layer.shadowRadius = 1
        
        logOutButton.layer.cornerRadius = 12
        logOutButton.layer.borderWidth = 1
        logOutButton.layer.masksToBounds = false
        logOutButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        logOutButton.layer.shadowOpacity = 0.3
        logOutButton.layer.shadowRadius = 1
    }
    
    @objc func personalInfoTapped() {
        let vc = PersonalInformationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func friendListTapped() {
        _ = self.tabBarController?.selectedIndex = 1
//        Task.init {
//            do {
//                let vc = try await OtherUserViewController(otherUser: user!)
//                await navigationController?.pushViewController(vc, animated: true)
//            } catch {
//                print("Phat nguuu")
//            }
//        }
        
    }
    
    @objc func darkModeTapped() {
        let vc = DarkModeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logOutButtonTapped() {

            let actionAlert = UIAlertController(title: "Do you wanna logout?", message: "Choose Log Out to Logout", preferredStyle: .alert)
            
            actionAlert.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { [weak self] _ in
                
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

