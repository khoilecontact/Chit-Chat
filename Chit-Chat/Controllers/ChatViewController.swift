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
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage
import UserNotifications

class ChatViewController: UIViewController {
    
    private var conversations = [MessagesCollection]()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search conversations"
        return searchBar
    }()
    
    private let noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversation"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        // register
        table.register(ChatsViewCell.self, forCellReuseIdentifier: ChatsViewCell.identifier)
        return table
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navBar()
        
        // subviews
        subViews()
        
        // config
        configSearchBar()
        configTableView()
        
        // sendNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        
        let a = UserDefaults.standard.value(forKey: "email")
        let b = UserDefaults.standard.value(forKey: "name")
        
        // start
        startListeningForConversations()
        createLoginObserver()
        // screenConversations(false)
        
        // Listen for new messages
        MessageNotificationCenter.shared.notifyNewMessage()
        
        // Listening for calls
        listeningForCalls()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationLabel.frame = CGRect(x: 10,
                                           y: (view.height-100)/2,
                                           width: view.width-20,
                                           height: 100)
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
    
    func listeningForCalls() {
        CallNotificationCenter.shared.listenForIncomingCall(completion: {
            [weak self] result in
            
            switch result {
            case .success(let data):
                guard let otherUserEmail = data["email"] as? String,
                      let otherUserName = data["name"] as? String,
                      let type = data["type"] as? String else { return }
                
                let vc = UIStoryboard(name: "IncomingCall", bundle: nil).instantiateViewController(withIdentifier: "IncomingCall") as! IncomingCallViewController
                vc.otherUserEmail = otherUserEmail
                vc.otherUserName = otherUserName
                vc.callType = type
                
                self?.present(vc, animated: true)
                
                break
                
            case .failure(_):
                
                break
            }
        })
    }
    
    private func startListeningForConversations() {
        
        self.spinner.show(in: view)
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
        let name = UserDefaults.standard.value(forKey: "name") as? String
        else {
            
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

                self.present(nav, animated: true)
            } catch {
                print("Error in signing out")
            }
            
            return
            
        }
        
        if let observer = loginObserver {
            // Listen for login => after login has been listen, remove observer
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let messagesCollection):
                guard !messagesCollection.isEmpty else {
                    strongSelf.screenConversations(false)
                    return
                }
                strongSelf.screenConversations(true)
                strongSelf.conversations = messagesCollection
                
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                    strongSelf.spinner.dismiss()
                }
            case .failure(let error):
                strongSelf.screenConversations(false)
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                print("Failed to get conversations: \(error)")
            }
        }
    }
    
    func subViews() {
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
    }
    
    func navBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        // rightBarButton
        let groupConversations = UIBarButtonItem(image: UIImage(systemName: "person.2.circle"), style: .plain, target: self, action: #selector(groupConversationTapped))
        navigationItem.rightBarButtonItem = groupConversations
    }
    
    func configSearchBar() {
        searchBar.delegate = self
    }
    
    func configTableView() {
        // delegate & dataSrc
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func createLoginObserver() {
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: {
            [weak self] notification in
            
            guard let strongSelf = self else { return }
            
            strongSelf.startListeningForConversations()
        })
    }
    
    func openConversation(_ model: MessagesCollection) {
        // open chat space
        let vc = MessageChatViewController(with: model.otherUserEmail, name: model.name, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openOtherFunctions() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // actions
        ac.addAction(UIAlertAction(title: "Mute notifications", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Something's wrong", style: .default, handler: nil))
        // cancel ac
        ac.addAction(UIAlertAction(title: "Block", style: .destructive, handler: nil))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true)
    }
    
    private func screenConversations(_ notEmpty: Bool) {
            if notEmpty {
                tableView.isHidden = false
                noConversationLabel.isHidden = true
            }
            else {
                noConversationLabel.isHidden = false
                tableView.isHidden = true
            }
    }
    
    @objc func groupConversationTapped() {
        let vc = GroupConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
//    func sendNotification() {
//        let notificationContent = UNMutableNotificationContent()
//        notificationContent.title = "Test"
////        notificationContent.subtitle = "Subtitle"
//        notificationContent.body = "Test body"
//        notificationContent.badge = NSNumber(value: 1)
//        
//        if let url = Bundle.main.url(forResource: "dune",
//                                    withExtension: "png") {
//            if let attachment = try? UNNotificationAttachment(identifier: "dune",
//                                                            url: url,
//                                                            options: nil) {
//                notificationContent.attachments = [attachment]
//            }
//        }
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
//                                                        repeats: false)
//        let request = UNNotificationRequest(identifier: "testNotification",
//                                            content: notificationContent,
//                                            trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { (error) in
//            if let error = error {
//                print("Notification Error: ", error)
//            }
//        }
//    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model: MessagesCollection = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatsViewCell.identifier, for: indexPath) as! ChatsViewCell
        // config cell
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: MessagesCollection = conversations[indexPath.row]
        openConversation(model)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let seeProfileAction = UIContextualAction(style: .destructive, title: "See Profile") { action, view, handler in
            // code
        }
        seeProfileAction.backgroundColor = GeneralSettings.primaryColor
        
        let configuration = UISwipeActionsConfiguration(actions: [seeProfileAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // actions
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, handler in
            
            guard let strongSelf = self else { return }
            
            // begin delete
            let conversationId = strongSelf.conversations[indexPath.row].id
            
            tableView.beginUpdates()
            /// Not put 2 line below in closure bc it will crash by startListenConversations will call 2 times.
            strongSelf.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                
                if !success {
                    print("Failed to delete")
                }
            })
            
            tableView.endUpdates()
        }
        // RGB: (211, 33, 44)
        // 242 78 30
        deleteAction.backgroundColor = UIColor(red: 242/255, green: 78/255, blue: 30/255, alpha: 1)
        
        let othersAction = UIContextualAction(style: .destructive, title: "Others") { [weak self] action, view, handler in
            guard let strongSelf = self else { return }
            strongSelf.openOtherFunctions()
        }
        // RGB: (6, 156, 86)
        othersAction.backgroundColor = UIColor(red: 6/255, green: 214/255, blue: 159/255, alpha: 1)
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, othersAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension ChatViewController: UISearchBarDelegate {
    
}
