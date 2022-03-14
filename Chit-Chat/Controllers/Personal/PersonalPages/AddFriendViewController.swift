//
//  NotAddedFriendViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 10/03/2022.
//

import UIKit
import FirebaseAuth

class AddFriendViewController: UIViewController {
    var otherUser: User?
    var friendStatus = "Stranger"
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: 320, height: 900)
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = Appearance.tint
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.tint
        label.textAlignment = .center
        label.font.withSize(20)
        return label
    }()
    
    let addFriendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Friend", for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 12

        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        button.imageView?.tintColor = Appearance.tint
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    let functionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis.circle")?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFit), for: .normal)
        
        return button
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.tint
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.layer.borderColor = Appearance.tint.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 12
        label.layer.backgroundColor = UIColor.systemBackground.cgColor
        
        return label
    }()
    
    let dobIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "gift.fill")
        imageView.tintColor = Appearance.tint
        return imageView
    }()
    
    let dobLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.tint
        return label
    }()
    
    let genderIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = Appearance.tint
        return imageView
    }()
    
    let genderLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.tint
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFriendButton.addTarget(self, action: #selector(addFriendTapped), for: .touchUpInside)
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(functionsButton)
        scrollView.addSubview(addFriendButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(dobIcon)
        scrollView.addSubview(dobLabel)
        scrollView.addSubview(genderIcon)
        scrollView.addSubview(genderLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: size, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        nameLabel.frame = CGRect(x: 40, y: imageView.bottom + 5, width: scrollView.width - 80, height: 52)
        
        functionsButton.frame = CGRect(x: scrollView.right - 40, y: nameLabel.bottom + 10, width: 40, height: 52)
        
        addFriendButton.frame = CGRect(x: 80, y: nameLabel.bottom + 10, width: scrollView.width - 160, height: 40)
        
        bioLabel.frame = CGRect(x: 20, y: addFriendButton.bottom + 30, width: scrollView.width - 40, height: 52)
        
        dobIcon.frame = CGRect(x: 20, y: bioLabel.bottom + 40, width: 30, height: 52)
        
        dobLabel.frame = CGRect(x: dobIcon.right + 20, y: bioLabel.bottom + 40, width: scrollView.width - 70, height: 52)
        
        genderIcon.frame = CGRect(x: 20, y: dobIcon.bottom + 30, width: 30, height: 40)
        
        genderLabel.frame = CGRect(x: genderIcon.right + 20, y: dobIcon.bottom + 30, width: scrollView.width - 100, height: 52)
    }
    
    init(otherUser: User) {
        super.init(nibName: nil, bundle: nil)
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        self.otherUser = otherUser
        
        guard let pageUser = self.otherUser else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        // Get list data of user
        getAllOtherInfoUser()
        
        // Loading user's image
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
        
        title = otherUser.firstName + " " + otherUser.lastName
        
        nameLabel.text = otherUser.firstName + " " + otherUser.lastName
        
        bioLabel.text = (otherUser.bio == "") ? "This user has no bio yet" : otherUser.bio
        
        dobLabel.text = otherUser.dob
        
        genderLabel.text = otherUser.isMale ? "Male" : "Female"
        
        // Check for friend status
        // Case: They sent you a sent request
        for user in pageUser.sentfriendRequestList {
            if user.email == currentUserEmail {
                friendStatus = "Received"
            }
        }
        // Case: You have sent them a friend request
        for user in pageUser.friendRequestList {
            if user.email == currentUserEmail {
                friendStatus = "Sent"
            }
        }
        // Case: You're friends
        for user in pageUser.friendList {
            if user.email == currentUserEmail {
                friendStatus = "Added"
            }
        }
        // Case: Nobody sent a friend request
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getAllOtherInfoUser() {
        guard let otherUser = otherUser else { return }
        
        // Getting user's friend list
        DatabaseManager.shared.getAllFriendsOfUser(with: otherUser.email, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in get all friend list: \(error)")
                return
            
            case .success(let data):
                self?.otherUser?.friendList = data.compactMap{
                    guard let id = $0["id"] as? String,
                          let email = $0["email"] as? String,
                          let lastName = $0["last_name"] as? String,
                          let firstName = $0["first_name"] as? String,
                          let bio = $0["bio"] as? String?,
                          let dob = $0["dob"] as? String?,
                          let isMale = $0["is_male"] as? Bool,
                          let province = $0["province"] as? String,
                          let district = $0["district"] as? String
                    else {
                        print("excepted type")
                        return nil
                    }
                    
                    return UserNode(id: id,
                                    firstName: firstName,
                                    lastName: lastName,
                                    province: province,
                                    district: district,
                                    bio: bio ?? "",
                                    email: email,
                                    dob: dob ?? "",
                                    isMale: isMale)
                }
                
                break
            }
        })
        
        // Get user's friend request
        DatabaseManager.shared.getAllFriendRequestOfUser(with: otherUser.email, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in get all friend request list: \(error)")
                return
            
            case .success(let data):
                self?.otherUser?.friendRequestList = data.compactMap{
                    guard let id = $0["id"] as? String,
                          let email = $0["email"] as? String,
                          let lastName = $0["last_name"] as? String,
                          let firstName = $0["first_name"] as? String,
                          let bio = $0["bio"] as? String?,
                          let dob = $0["dob"] as? String?,
                          let isMale = $0["is_male"] as? Bool,
                          let province = $0["province"] as? String,
                          let district = $0["district"] as? String
                    else {
                        print("excepted type")
                        return nil
                    }
                    
                    return UserNode(id: id,
                                    firstName: firstName,
                                    lastName: lastName,
                                    province: province,
                                    district: district,
                                    bio: bio ?? "",
                                    email: email,
                                    dob: dob ?? "",
                                    isMale: isMale)
                }
                
                break
            }
            
        })
        
        // Get user's sent friend request
        DatabaseManager.shared.getAllSentFriendRequestOfUser(with: otherUser.email, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in get all friend request list: \(error)")
                return
            
            case .success(let data):
                self?.otherUser?.sentfriendRequestList = data.compactMap{
                    guard let id = $0["id"] as? String,
                          let email = $0["email"] as? String,
                          let lastName = $0["last_name"] as? String,
                          let firstName = $0["first_name"] as? String,
                          let bio = $0["bio"] as? String?,
                          let dob = $0["dob"] as? String?,
                          let isMale = $0["is_male"] as? Bool,
                          let province = $0["province"] as? String,
                          let district = $0["district"] as? String
                    else {
                        print("excepted type")
                        return nil
                    }
                    
                    return UserNode(id: id,
                                    firstName: firstName,
                                    lastName: lastName,
                                    province: province,
                                    district: district,
                                    bio: bio ?? "",
                                    email: email,
                                    dob: dob ?? "",
                                    isMale: isMale)
                }
                
                break
            }
        })
        
        // Get user's sent friend request
        DatabaseManager.shared.getBlackListOfUser(with: otherUser.email, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in get all friend request list: \(error)")
                return
            
            case .success(let data):
                self?.otherUser?.blackList = data.compactMap{
                    guard let id = $0["id"] as? String,
                          let email = $0["email"] as? String,
                          let lastName = $0["last_name"] as? String,
                          let firstName = $0["first_name"] as? String,
                          let bio = $0["bio"] as? String?,
                          let dob = $0["dob"] as? String?,
                          let isMale = $0["is_male"] as? Bool,
                          let province = $0["province"] as? String,
                          let district = $0["district"] as? String
                    else {
                        print("excepted type")
                        return nil
                    }
                    
                    return UserNode(id: id,
                                    firstName: firstName,
                                    lastName: lastName,
                                    province: province,
                                    district: district,
                                    bio: bio ?? "",
                                    email: email,
                                    dob: dob ?? "",
                                    isMale: isMale)
                }
                
                break
            }
        })
    }
    
    @objc func addFriendTapped() {
        guard let user = otherUser else { return }
        
        let otherUser = UserNode(id: user.id, firstName: user.firstName, lastName: user.lastName, province: user.province, district: user.district, bio: user.bio, email: user.email, dob: user.dob, isMale: user.isMale)
        
        DatabaseManager.shared.sendFriendRequest(with: otherUser, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in sending friend request: \(error)")
                break
                
            case .success( _):
                let ac = UIAlertController(title: "Friend Request Sent", message: "Yout friend request has been sent", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true, completion: nil)
                break
            }
            
        })
        
        // Update the button
        addFriendButton.setTitle("Request sent", for: .normal)
        addFriendButton.setImage(UIImage(systemName: "airplane"), for: .normal)
        addFriendButton.backgroundColor = UIColor.systemGray2
    }
    
}
