//
//  FriendsViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 03/02/2022.
//

import Foundation
import UIKit
import JGProgressHUD

class FriendsViewController: UIViewController {
    
    private var friends = [User]()
    
    private let tabNumber: Bool = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Seach for someone ..."
        return bar
    }()
    
    private let tableView: UITableView = {
        var table = UITableView()
        table.isHidden = false
        table.register(FriendsCell.self, forCellReuseIdentifier: FriendsCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // fake data
        let latestMessage = LatestMessage(date: Date(), text: "Hello World", isRead: false)
        
        let conversations = MessagesCollection(id: "fir5tM3ss4g35", name: "Doctor", otherUserEmail: "yds@gm.yds.edu.vn", latestMessage: latestMessage)
        
        let node = UserNode(id: "hash123",
                            firstName: "Khoi",
                            lastName: "Le",
                            bio: "This is my bio",
                            email: "uit@gm.uit.edu.vn",
                            dob: Date(),
                            isMale: true)
        
        friends.append(User(id: "hash123",
                            firstName: "Khoi",
                            lastName: "Le",
                            bio: "This is bio",
                            email: "uit@gm.uit.edu.vn",
                            password: "SwiftyHash",
                            dob: Date(),
                            isMale: true,
                            friendList: [node],
                            conversations: [conversations]))
        friends.append(User(id: "hash124",
                            firstName: "Phat",
                            lastName: "Nguyen",
                            bio: "This is bio",
                            email: "sub-uit@gm.uit.edu.vn",
                            password: "SwiftyHash",
                            dob: Date(),
                            isMale: true,
                            friendList: [node],
                            conversations: [conversations]))
        
        // --- ---
        
        navigationBar()
        setupSearchBar()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            tableView.frame = view.bounds
        }
    
    func navigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(findNewFriend))
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        // searchBar.becomeFirstResponder()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func openConversation(_ model: User) {
        
    }
    
    @objc func findNewFriend() {
        
    }
}

// MARK: - Config TableView
extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
   }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsCell.identifier, for: indexPath) as! FriendsCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = friends[indexPath.row]
        openConversation(model)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
//            let conversationId = conversations[indexPath.row].id
            
            tableView.beginUpdates()
            /// Not put 2 line below in closure bc it will crash by startListenConversations will call 2 times.
//            conversations.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .left)
//
//            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
//
//                if !success {
//                    print("Failed to delete")
//                }
//            })
            
            tableView.endUpdates()
        }
    }
}

// MARK: - Config SeachBar
extension FriendsViewController: UISearchBarDelegate {
    
}
