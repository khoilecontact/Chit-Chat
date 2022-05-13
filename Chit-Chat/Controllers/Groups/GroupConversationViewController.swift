//
//  GroupConversationViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/05/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD

class GroupConversationViewController: UIViewController {

    private var conversations = [GroupMessagesCollection]()
        
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
            table.register(GroupChatsViewCell.self, forCellReuseIdentifier: GroupChatsViewCell.identifier)
            return table
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            navBar()
            
            // subviews
            subViews()
            fakeData()
            
            // config
            configTableView()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            validateAuth()
            
            // start
            // startListeningForConversations()
            // screenConversations(false)
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
        
        private func startListeningForConversations() {
            
//            self.spinner.show(in: view)
//
//            guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
//
//            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//
//            DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] result in
//                guard let strongSelf = self else { return }
//
//                switch result {
//                case .success(let messagesCollection):
//                    guard !messagesCollection.isEmpty else {
//                        strongSelf.screenConversations(false)
//                        return
//                    }
//                    strongSelf.screenConversations(true)
//                    strongSelf.conversations = messagesCollection
//
//                    DispatchQueue.main.async {
//                        strongSelf.tableView.reloadData()
//                        strongSelf.spinner.dismiss()
//                    }
//                case .failure(let error):
//                    strongSelf.screenConversations(false)
//                    DispatchQueue.main.async {
//                        self?.spinner.dismiss()
//                    }
//                    print("Failed to get conversations: \(error)")
//                }
//            }
        }
        
        func subViews() {
            view.addSubview(tableView)
            view.addSubview(noConversationLabel)
        }
        
        // MARK: - FAKE DATA
        func fakeData() {
            let latestMessage = LatestMessage(date: "20/12/2009", text: "Hello World", isRead: false)
            
            conversations.append(GroupMessagesCollection(id: "fir5tM3ss4g35", name: "Doctor", latestMessage: latestMessage))
            conversations.append(GroupMessagesCollection(id: "s3c0ndM3ss4g35", name: "IT", latestMessage: latestMessage))
            
            screenConversations(true)
            
        }
        // --- ---
        
        func navBar() {
            navigationController?.navigationBar.topItem?.titleView = searchBar
            // rightBarButton
        }
        
        func configTableView() {
            // delegate & dataSrc
            tableView.delegate = self
            tableView.dataSource = self
        }
        
        func openConversation(_ model: GroupMessagesCollection) {
            // open chat space
            let vc = GroupChatViewController(with: model.id, name: model.name)
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
    }

    extension GroupConversationViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return conversations.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let model: GroupMessagesCollection = conversations[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatsViewCell.identifier, for: indexPath) as! GroupChatsViewCell
            // config cell
            cell.configure(with: model)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let model: GroupMessagesCollection = conversations[indexPath.row]
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
