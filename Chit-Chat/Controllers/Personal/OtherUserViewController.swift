//
//  NotAddedFriendViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 10/03/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OtherUserViewController: UIViewController {
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
    
    // Cases for friend status
    
    // Request Sent
    let requestSentButton: UIButton = {
        let button = UIButton()
        button.setTitle("Request Sent", for: .normal)
        button.backgroundColor = UIColor.systemGray2
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "airplane"), for: .normal)
        button.imageView?.tintColor = Appearance.tint
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    // Stranger
    let addFriendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Friend", for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 20
        
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
    
    // Received a friend request
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Confirm", for: .normal)
        button.backgroundColor = .init(red: CGFloat(108) / 255.0, green: CGFloat(164) / 255.0, blue: CGFloat(212) / 255.0, alpha: 1.0)
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.imageView?.tintColor = Appearance.tint
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "xmark.square"), for: .normal)
        button.imageView?.tintColor = Appearance.tint
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    // Added friend
    let friendStatusButton: UIButton = {
        let button = UIButton()
        button.setTitle("Friend", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 1
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "person.fill.checkmark"), for: .normal)
        button.imageView?.tintColor = Appearance.tint
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Message", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(Appearance.tint, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.imageView?.tintColor = Appearance.tint
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    // Rest of the view
    
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
        
        requestSentButton.addTarget(self, action: #selector(requestSentButtonTapped), for: .touchUpInside)
        
        friendStatusButton.addTarget(self, action: #selector(friendStatusButtonTapped), for: .touchUpInside)
//        messageButton
//
//        confirmButton
//        cancelButton
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(functionsButton)
        scrollView.addSubview(addFriendButton)
        scrollView.addSubview(requestSentButton)
        scrollView.addSubview(confirmButton)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(friendStatusButton)
        scrollView.addSubview(messageButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(dobIcon)
        scrollView.addSubview(dobLabel)
        scrollView.addSubview(genderIcon)
        scrollView.addSubview(genderLabel)
    }
    
    func initLayout() {
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: size, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        nameLabel.frame = CGRect(x: 40, y: imageView.bottom + 5, width: scrollView.width - 80, height: 52)
        
        functionsButton.frame = CGRect(x: scrollView.right - 40, y: nameLabel.bottom + 10, width: 40, height: 52)
        
        switch friendStatus {
        case "Sent":
            requestSentButton.frame = CGRect(x: 80, y: nameLabel.bottom + 10, width: scrollView.width - 160, height: 40)
            
            bioLabel.frame = CGRect(x: 20, y: requestSentButton.bottom + 30, width: scrollView.width - 40, height: 52)
            break
            
        case "Added":
            friendStatusButton.frame = CGRect(x: 50, y: nameLabel.bottom + 10, width: 130, height: 40)
            
            messageButton.frame = CGRect(x: friendStatusButton.right + 20, y: nameLabel.bottom + 10, width: 130, height: 40)
            
            bioLabel.frame = CGRect(x: 20, y: friendStatusButton.bottom + 30, width: scrollView.width - 40, height: 52)
            break
            
        case "Received":
            confirmButton.frame = CGRect(x: 50, y: nameLabel.bottom + 10, width: 130, height: 40)
            
            cancelButton.frame = CGRect(x: confirmButton.right + 20, y: nameLabel.bottom + 10, width: 130, height: 40)
            
            bioLabel.frame = CGRect(x: 20, y: confirmButton.bottom + 30, width: scrollView.width - 40, height: 52)
            break
            
        default:
            // Stranger
            addFriendButton.frame = CGRect(x: 80, y: nameLabel.bottom + 10, width: scrollView.width - 160, height: 40)
            
            bioLabel.frame = CGRect(x: 20, y: addFriendButton.bottom + 30, width: scrollView.width - 40, height: 52)
            break
        }
        
        dobIcon.frame = CGRect(x: 20, y: bioLabel.bottom + 40, width: 30, height: 52)
        
        dobLabel.frame = CGRect(x: dobIcon.right + 20, y: bioLabel.bottom + 40, width: scrollView.width - 70, height: 52)
        
        genderIcon.frame = CGRect(x: 20, y: dobIcon.bottom + 30, width: 30, height: 40)
        
        genderLabel.frame = CGRect(x: genderIcon.right + 20, y: dobIcon.bottom + 30, width: scrollView.width - 100, height: 52)
    }
    
    init(otherUser: User) {
        super.init(nibName: nil, bundle: nil)
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        self.otherUser = otherUser
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        // Get list data of user
        UserAdvancedManager.shared.getAllFriendOfUser(with: otherUser.email, completion: { friendList in
            UserAdvancedManager.shared.getAllFriendRequestOfUser(with: otherUser.email, completion: { friendRequest in
                UserAdvancedManager.shared.getAllSentFriendRequestOfUser(with: otherUser.email, completion: { sentRequest in
                    UserAdvancedManager.shared.getAllBlacklistOfUser(with: otherUser.email, completion: { [weak self] blacklist in
                        self?.otherUser?.friendList = friendList
                        self?.otherUser?.friendRequestList = friendRequest
                        self?.otherUser?.sentfriendRequestList = sentRequest
                        self?.otherUser?.blackList = blacklist
                        
                        guard let pageUser = self?.otherUser else {
                            return
                        }
                        
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
                        
                        self?.title = otherUser.firstName + " " + otherUser.lastName
                        
                        self?.nameLabel.text = otherUser.firstName + " " + otherUser.lastName
                        
                        self?.bioLabel.text = (otherUser.bio == "") ? "This user has no bio yet" : otherUser.bio
                        
                        self?.dobLabel.text = otherUser.dob
                        
                        self?.genderLabel.text = otherUser.isMale ? "Male" : "Female"
                        // Check for friend status
                        // Case: They sent you a sent request
                        for user in pageUser.sentfriendRequestList {
                            if user.email == currentUserEmail {
                                self?.friendStatus = "Received"
                            }
                        }
                        // Case: You have sent them a friend request
                        for user in pageUser.friendRequestList {
                            if user.email == currentUserEmail {
                                self?.friendStatus = "Sent"
                            }
                        }
                        // Case: You're friends
                        for user in pageUser.friendList {
                            if user.email == currentUserEmail {
                                self?.friendStatus = "Added"
                            }
                        }
                        // Case: Nobody sent a friend request
                        
                        self?.initLayout()
                    })
                })
            })
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        DispatchQueue.main.async {
            self.friendStatus = "Sent"
            self.addFriendButton.isHidden = true
            self.addFriendButton.removeFromSuperview()
            
            self.requestSentButton.isHidden = false
            self.requestSentButton.frame = CGRect(x: 80, y: self.nameLabel.bottom + 10, width: self.scrollView.width - 160, height: 40)
            
            self.bioLabel.frame = CGRect(x: 20, y: self.requestSentButton.bottom + 30, width: self.scrollView.width - 40, height: 52)
        }
        
    }
    
    @objc func requestSentButtonTapped() {
        guard let user = self.otherUser else { return }
        let userNode: UserNode = user.toUserNode()
        
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {_ in
            DatabaseManager.shared.deniesFriendRequest(with: userNode, completion: { result in
                switch result {
                case .failure( _):
                    let secondAlert = UIAlertController(title: "Failed", message: "Failed to revoke request", preferredStyle: .alert)
                    secondAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    break
                    
                case .success(let success):
                    if success {
                        DispatchQueue.main.async {
                            self.friendStatus = "Stranger"
                            self.requestSentButton.isHidden = true
                            self.requestSentButton.removeFromSuperview()
                            
                            self.addFriendButton.isHidden = false
                            self.addFriendButton.frame = CGRect(x: 80, y: self.nameLabel.bottom + 10, width: self.scrollView.width - 160, height: 40)
                            
                            self.bioLabel.frame = CGRect(x: 20, y: self.addFriendButton.bottom + 30, width: self.scrollView.width - 40, height: 52)
                        }
                    }
                    break
                }
            })
        }))
    }
    
    @objc func friendStatusButtonTapped() {
        guard let user = self.otherUser else { return }
        let userNode: UserNode = user.toUserNode()
        
        let vc = UIViewController()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 2
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
            
        let alert = UIAlertController(title: "Change friend status", message: "",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Unfriend", style: .default, handler: { (alert: UIAlertAction) in 
            DatabaseManager.shared.unfriend(with: userNode, completion: { [weak self] result in
                switch result {
                case .failure(_):
                    let secondAlert = UIAlertController(title: "Failed", message: "Something when wrong, please try again later", preferredStyle: .alert)
                    secondAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self?.present(secondAlert, animated: true)
                    break
                case .success(_):
                    self?.friendStatus = "Stranger"
                    self?.initLayout()
                    break
                }
                
            })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
