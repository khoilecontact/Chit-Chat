//
//  NotAddedFriendViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 10/03/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD

class OtherUserViewController: UIViewController {
    var otherUser: User?
    var friendStatus = "Stranger"
    
    private var users = [[String: Any]]()
    private var results = [UserNode]()
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.tint
        label.textAlignment = .center
        label.font = UIFont(name: "Trebuchet MS Bold", size: 20)
        return label
    }()
    
    // Cases for friend status
    
    // Request Sent
    let requestSentButton: UIButton = {
        let button = UIButton()
        button.setTitle("Request Sent", for: .normal)
        button.backgroundColor = UIColor.systemGray2
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "airplane"), for: .normal)
        button.imageView?.tintColor = UIColor.white
        
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
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        button.imageView?.tintColor = UIColor.white
        
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
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.imageView?.tintColor = UIColor.white
        
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
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "xmark.square"), for: .normal)
        button.imageView?.tintColor = UIColor.white
        
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
        button.layer.borderColor = UIColor.systemGray2.cgColor
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
        button.backgroundColor = Appearance.appColor
        //button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        
        button.layer.borderWidth = 0
        button.titleLabel?.textAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.imageView?.tintColor = UIColor.white
        
        // Add shadow
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        
        return button
    }()
    
    // Blocked
    let blockIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill.xmark")
        imageView.tintColor = Appearance.tint
        return imageView
    }()
    
    let blockLabel: UILabel = {
        let label = UILabel()
        label.text = "Current user is not available!"
        label.textColor = UIColor.gray
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    // Rest of the view
    
    let functionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis.circle.fill")?.sd_resizedImage(with: CGSize(width: 35, height: 35), scaleMode: .aspectFit)?.withTintColor(UIColor.systemGray2), for: .normal)
        
        return button
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.tint
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.layer.borderColor = Appearance.tint.cgColor
        label.layer.borderWidth = 0
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
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)

        confirmButton.addTarget(self, action: #selector(confirmRequestTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelRequestTapped), for: .touchUpInside)
        
        functionsButton.addTarget(self, action: #selector(functionButtonTapped), for: .touchUpInside)
        
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
        scrollView.addSubview(functionsButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(dobIcon)
        scrollView.addSubview(dobLabel)
        scrollView.addSubview(genderIcon)
        scrollView.addSubview(genderLabel)
        
        scrollView.addSubview(blockLabel)
        scrollView.addSubview(blockIcon)
    }
    
    init(otherUser: User) {
        super.init(nibName: nil, bundle: nil)
        
        spinner.show(in: view)
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        self.otherUser = otherUser
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        DispatchQueue.global(qos: .background).async {
            // Get list data of user
            UserAdvancedManager.shared.getAllFriendOfUser(with: otherUser.email, completion: { friendList in
                UserAdvancedManager.shared.getAllFriendRequestOfUser(with: otherUser.email, completion: { friendRequest in
                    UserAdvancedManager.shared.getAllSentFriendRequestOfUser(with: otherUser.email, completion: { sentRequest in
                        UserAdvancedManager.shared.getAllBlacklistOfUser(with: otherUser.email, completion: { [weak self] blacklist in
                            UserAdvancedManager.shared.getAllBlacklistOfUser(with: currentUserEmail, completion: { currentBlackList in
                                self?.otherUser?.friendList = friendList
                                self?.otherUser?.friendRequestList = friendRequest
                                self?.otherUser?.sentfriendRequestList = sentRequest
                                self?.otherUser?.blackList = blacklist
                                
                                guard let pageUser = self?.otherUser else {
                                    return
                                }
                                
                                for user in currentBlackList {
                                    if user.email == pageUser.email {
                                        self?.friendStatus = "Blocked"
                                        break
                                    }
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
                                        self?.imageView.backgroundColor = .white
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
                                        break
                                    }
                                }
                                // Case: You have sent them a friend request
                                for user in pageUser.friendRequestList {
                                    if user.email == currentUserEmail {
                                        self?.friendStatus = "Sent"
                                        break
                                    }
                                }
                                // Case: You're friends
                                for user in pageUser.friendList {
                                    if user.email == currentUserEmail {
                                        self?.friendStatus = "Added"
                                        break
                                    }
                                }
                                // Case: You or they block each other
                                // other user's blacklist
                                for user in pageUser.blackList {
                                    if user.email == currentUserEmail {
                                        self?.friendStatus = "Blocked"
                                        break
                                    }
                                }
                                
                                // Case: Nobody sent a friend request
                                
                                self?.initLayout()
                                
                                DispatchQueue.main.async {
                                    self?.spinner.dismiss()
                                }
                        
                            })
                        })
                    })
                })
            })
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initLayout() {
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        var bottomDynamicUI = 0
        
        imageView.frame = CGRect(x: size, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        nameLabel.frame = CGRect(x: 40, y: imageView.bottom + 5, width: scrollView.width - 80, height: 52)
        
        switch friendStatus {
        case "Sent":
            bioLabel.frame = CGRect(x: 20, y: nameLabel.bottom, width: scrollView.width - 40, height: 30)
            
            requestSentButton.frame = CGRect(x: 80, y: bioLabel.bottom + 10, width: scrollView.width - 160, height: 40)
            
            functionsButton.frame = CGRect(x: scrollView.right - 40, y: bioLabel.bottom + 10, width: 40, height: 52)
            
            break
            
        case "Added":
            bioLabel.frame = CGRect(x: 20, y: nameLabel.bottom, width: scrollView.width - 40, height: 30)
            
            friendStatusButton.frame = CGRect(x: 50, y: bioLabel.bottom + 10, width: 130, height: 40)
            
            messageButton.frame = CGRect(x: friendStatusButton.right + 20, y: bioLabel.bottom + 10, width: 130, height: 40)
            
            functionsButton.frame = CGRect(x: scrollView.right - 40, y: bioLabel.bottom + 10, width: 40, height: 52)
            
            break
            
        case "Received":
            bioLabel.frame = CGRect(x: 20, y: nameLabel.bottom, width: scrollView.width - 40, height: 30)
            
            confirmButton.frame = CGRect(x: 50, y: bioLabel.bottom + 10, width: 130, height: 40)
            
            cancelButton.frame = CGRect(x: confirmButton.right + 20, y: bioLabel.bottom + 10, width: 130, height: 40)
            
            functionsButton.frame = CGRect(x: scrollView.right - 40, y: bioLabel.bottom + 10, width: 40, height: 52)
            
            break
            
        case "Blocked":
            // Handle UI for blocked person
            imageView.removeFromSuperview()
            nameLabel.removeFromSuperview()
            functionsButton.removeFromSuperview()
            dobIcon.removeFromSuperview()
            dobLabel.removeFromSuperview()
            genderIcon.removeFromSuperview()
            genderLabel.removeFromSuperview()
            
            blockIcon.frame = CGRect(x: 120, y: 200, width: 200, height: 180)
            blockLabel.frame = CGRect(x: 60, y: blockIcon.bottom - 100, width: 290, height: 290)
            
            break
            
        default:
            // Stranger
            bioLabel.frame = CGRect(x: 20, y: nameLabel.bottom, width: scrollView.width - 40, height: 30)
            
            addFriendButton.frame = CGRect(x: 80, y: bioLabel.bottom + 10, width: scrollView.width - 160, height: 40)
            
            functionsButton.frame = CGRect(x: scrollView.right - 40, y: bioLabel.bottom + 10, width: 40, height: 52)
            break
        }
        
        dobIcon.frame = CGRect(x: 20, y: functionsButton.bottom + 20, width: 30, height: 52)
        
        dobLabel.frame = CGRect(x: dobIcon.right + 20, y: functionsButton.bottom + 20, width: scrollView.width - 70, height: 52)
        
        genderIcon.frame = CGRect(x: 20, y: dobIcon.bottom + 30, width: 30, height: 40)
        
        genderLabel.frame = CGRect(x: genderIcon.right + 20, y: dobIcon.bottom + 30, width: scrollView.width - 100, height: 52)
    }
    
    
    @objc func addFriendTapped() {
        guard let user = otherUser else { return }
        
        let otherUser = UserNode(id: user.id, firstName: user.firstName, lastName: user.lastName, province: user.province, district: user.district, bio: user.bio, email: user.email, dob: user.dob, isMale: user.isMale)
        
        DatabaseManager.shared.sendFriendRequest(with: otherUser, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in sending friend request: \(error)")
                
                let ac = UIAlertController(title: "Send Friend Request Failed", message: "There has been a error! Please try again later", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true, completion: nil)
                
                break
                
            case .success( _):
                let ac = UIAlertController(title: "Friend Request Sent", message: "Yout friend request has been sent", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true, completion: nil)
                
                // Update the button
                DispatchQueue.main.async {
                    self?.friendStatus = "Sent"
                    self?.addFriendButton.isHidden = true
                    //self?.addFriendButton.removeFromSuperview()
                    
                    self?.requestSentButton.isHidden = false
                    self?.initLayout()
                }
                
                break
            }
        })
        
    }
    
    @objc func requestSentButtonTapped() {
        guard let user = self.otherUser else { return }
        let userNode: UserNode = user.toUserNode()
        
        let alert = UIAlertController(title: "Revoke request?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {_ in
            DatabaseManager.shared.revokeFriendRequest(with: userNode, completion: { [weak self] result in
                switch result {
                case .failure( _):
                    let secondAlert = UIAlertController(title: "Failed", message: "Failed to revoke request", preferredStyle: .alert)
                    secondAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self?.present(secondAlert, animated: true)
                    break
                    
                case .success(let success):
                    if success {
                        DispatchQueue.main.async {
                            self?.friendStatus = "Stranger"
                            self?.requestSentButton.isHidden = true
                            //self?.requestSentButton.removeFromSuperview()
                            
                            self?.addFriendButton.isHidden = false
                            self?.initLayout()
                        }
                    }
                    break
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @objc func friendStatusButtonTapped() {
        guard let user = self.otherUser else { return }
        let userNode: UserNode = user.toUserNode()
        
        self.unfriend(with: userNode)
    }
    
    @objc func messageButtonTapped() {
        guard let user = self.otherUser else { return }
        var conversationId = ""
        let database = Database.database(url: GeneralSettings.databaseUrl).reference()
        
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: user.email)
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("Users/\(mySafeEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            if let conversations = snapshot.value as? [[String: Any]] {
                // Delete conversation of current user
                for conversationIndex in 0 ..< conversations.count {
                    if conversations[conversationIndex]["other_user_email"] as? String == otherSafeEmail {
                        conversationId = conversations[conversationIndex]["id"] as! String
                        break
                    }
                }
                
                let vc = MessageChatViewController(with: otherSafeEmail, name: user.firstName + " " + user.lastName, id: conversationId)
                vc.title = user.firstName + " " + user.lastName
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                let vc = MessageChatViewController(with: otherSafeEmail, name: user.firstName + " " + user.lastName, id: nil)
                vc.title = user.firstName + " " + user.lastName
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @objc func cancelRequestTapped() {
        guard let user = self.otherUser else { return }
        let userNode: UserNode = user.toUserNode()
        
        self.deniesRequest(with: userNode)
    }
    
    @objc func confirmRequestTapped() {
        guard let user = self.otherUser else { return }
        let userNode: UserNode = user.toUserNode()
        
        self.acceptRequest(with: userNode)
    }
    
    @objc func functionButtonTapped() {
        let alert = UIAlertController(title: "Manage", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { [weak self] (alert: UIAlertAction) in
            let confirmAlert = UIAlertController(title: "Are you sure you want to block this person?", message: nil, preferredStyle: .actionSheet)
            confirmAlert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { [weak self] (alert: UIAlertAction) in
                guard self?.otherUser != nil else { return }
                guard let otherUserNode = self?.otherUser!.toUserNode() as? UserNode else { return }

                // insert user into blacklist
                DatabaseManager.shared.addToBlackList(with: otherUserNode, completion: { result in
                    switch result {
                    case .success(_):
                        self?.dismiss(animated: true)
                        self?.friendStatus = "Blocked"
                        
                        self?.imageView.removeFromSuperview()
                        self?.nameLabel.removeFromSuperview()
                        self?.functionsButton.removeFromSuperview()
                        self?.addFriendButton.removeFromSuperview()
                        self?.requestSentButton.removeFromSuperview()
                        self?.confirmButton.removeFromSuperview()
                        self?.cancelButton.removeFromSuperview()
                        self?.friendStatusButton.removeFromSuperview()
                        self?.messageButton.removeFromSuperview()
                        self?.functionsButton.removeFromSuperview()
                        self?.bioLabel.removeFromSuperview()
                        self?.dobIcon.removeFromSuperview()
                        self?.dobLabel.removeFromSuperview()
                        self?.genderIcon.removeFromSuperview()
                        self?.genderLabel.removeFromSuperview()
                        
                        self?.initLayout()
                        break

                    case .failure(let err):
                        print("Error in adding to blacklist \(err)")
                        break
                    }
                })
            }))
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(confirmAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    
}

extension OtherUserViewController { 
    func deniesRequest(with user: UserNode) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        DatabaseManager.shared.getAllFriendRequestOfUser(with: email) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let requestData):
                strongSelf.users = requestData
                strongSelf.parseToFriendsRequest(with: requestData)
                
                // delete friend request
                DatabaseManager.shared.deniesFriendRequest(with: user) { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    switch result {
                    case .success(let finished):
                        if finished {
                            strongSelf.users.removeAll(where: {
                                guard let email = $0["email"] as? String else { return false }
                                
                                return email == user.email
                            })
                            
                            strongSelf.results.removeAll {
                                user.email == $0.email
                            }
                            
                            self?.friendStatus = "Stranger"
                            self?.confirmButton.isHidden = true
                            self?.cancelButton.isHidden = true
                            
                            self?.addFriendButton.isHidden = false
                            
                            self?.initLayout()
                        }
                        else {
                            print("Failed to finish denies request")
                            break
                        }
                        
                    case .failure(let error):
                        print("Failed to denies request: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to load friend request data: \(error)")
            }
        }
    }
    
    func acceptRequest(with user: UserNode) {
        DatabaseManager.shared.acceptFriendRequest(with: user) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let finished):
                if finished {
                    // remove from variable
                    strongSelf.users.removeAll(where: {
                        guard let email = $0["email"] as? String else { return false }
                        
                        return email == user.email
                    })
                    
                    strongSelf.results.removeAll {
                        user.email == $0.email
                    }
                    
                    self?.friendStatus = "Added"
                    self?.confirmButton.isHidden = true
                    self?.cancelButton.isHidden = true
                    
                    self?.initLayout()
                }
                else {
                    print("Failed to finish accept request")
                    break
                }
                
            case .failure(let error):
                print("Failed to accept request: \(error)")
            }
        }
    }
    
    func unfriend(with otherUser: UserNode) {
        let userNode: UserNode = otherUser
        
        let vc = UIViewController()
        let screenWidth = UIScreen.main.bounds.width - 10
        let screenHeight = UIScreen.main.bounds.height / 2
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
            
        let alert = UIAlertController(title: "Change friend status", message: "",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Unfriend", style: .default, handler: { [weak self] (alert: UIAlertAction) in
            let confirmAlert = UIAlertController(title: "Do you confirm to unfriend?", message: "This action can not be undo", preferredStyle: .actionSheet)
            confirmAlert.addAction(UIAlertAction(title: "Unfriend", style: .destructive, handler: { (alert: UIAlertAction) in
                DatabaseManager.shared.unfriend(with: userNode, completion: { [weak self] result in
                    switch result {
                    case .failure(_):
                        let secondAlert = UIAlertController(title: "Failed", message: "Something when wrong, please try again later", preferredStyle: .alert)
                        secondAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self?.present(secondAlert, animated: true)
                        break
                    case .success(_):
                        self?.friendStatus = "Stranger"
                        self?.friendStatusButton.isHidden = true
                        //self?.friendStatusButton.removeFromSuperview()
                        
                        self?.messageButton.isHidden = true
                        //self?.messageButton.removeFromSuperview()
                        
                        self?.initLayout()
                        break
                    }
                    
                })
            }))
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(confirmAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func parseToFriendsRequest(with listMap: [[String: Any]]) {
        results = listMap.compactMap{
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
    }
}
