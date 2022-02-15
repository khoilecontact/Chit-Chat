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
        
//        bioLabel.text = user.bio
//        bioLabel.textColor = UIColor.black
//        bioLabel.textAlignment = .center
        bioLabel.layer.borderWidth = 1
//        bioLabel.layer.borderColor = UIColor.black.cgColor
//        bioLabel.layer.cornerRadius = 12
//        bioLabel.layer.backgroundColor = UIColor.systemBackground.cgColor
        
    }
    
    private func createProfileModel() {

            let actionAlert = UIAlertController(title: "Do you wanna logout?", message: "Choose Log Out to Logout", preferredStyle: .alert)
            
            actionAlert.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(actionAlert, animated: true)
    }
}

