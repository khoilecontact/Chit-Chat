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
        // register
        table.register(ChatsViewCell.self, forCellReuseIdentifier: ChatsViewCell.identifier)
        return table
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        
        // fakeData
        fakeData()
        
        // subviews
        subViews()
        
        // config
        configSearchBar()
        configTableView()
        
        // start
        createLoginObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
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
    
    func subViews() {
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
    }
    
    // MARK: - FAKE DATA
    func fakeData() {
        let latestMessage = LatestMessage(date: Date(), text: "Hello World", isRead: false)
        
        conversations.append(MessagesCollection(id: "fir5tM3ss4g35", name: "Doctor", otherUserEmail: "yds@gm.yds.edu.vn", latestMessage: latestMessage))
        conversations.append(MessagesCollection(id: "s3c0ndM3ss4g35", name: "IT", otherUserEmail: "uit@gm.uit.edu.vn", latestMessage: latestMessage))
        
    }
    // --- ---
    
    func navBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        // rightBarButton
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
            
            // strongSelf.startListenConversations
        })
    }
    
    func openConversation(_ model: MessagesCollection) {
        // open chat space
    }
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
        openConversation(model);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let seeProfileAction = UIContextualAction(style: .destructive, title: "See Profile") { action, view, handler in
            // code
        }
        seeProfileAction.backgroundColor = UIColor(red: 108/255, green: 164/255, blue: 212/255, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [seeProfileAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // actions
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
            
        }
        // RGB: (211, 33, 44)
        // 242 78 30
        deleteAction.backgroundColor = UIColor(red: 242/255, green: 78/255, blue: 30/255, alpha: 1)
        
        let othersAction = UIContextualAction(style: .destructive, title: "Others") { action, view, handler in
            
        }
        // RGB: (6, 156, 86)
        othersAction.backgroundColor = UIColor(red: 6/255, green: 156/255, blue: 86/255, alpha: 1)
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, othersAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension ChatViewController: UISearchBarDelegate {
    
}
