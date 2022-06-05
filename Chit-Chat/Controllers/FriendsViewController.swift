//
//  FriendsViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 03/02/2022.
//

import Foundation
import UIKit
import JGProgressHUD
import FirebaseDatabase

class FriendsViewController: UIViewController {
    
    private var friends = [UserNode]()
    private var results = [UserNode]()
    
    private let tabNumber: Bool = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for someone ..."
        return bar
    }()
    
    private let tableView: UITableView = {
        var table = UITableView()
        table.isHidden = false
        table.register(FriendsCell.self, forCellReuseIdentifier: FriendsCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textColor = .green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // fakeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // start
        fetchFriendList()
        navigationBar()
        subLayouts()
        setupSearchBar()
        setupTableView()
        
        // Listen for new messages
        MessageNotificationCenter.shared.listenForNewMessage()
        
        // Listening for calls
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    func navigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        let findNewFriends = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(findNewFriend))
        let friendRequest = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(friendRequest))
        navigationItem.rightBarButtonItems = [findNewFriends, friendRequest]
    }
    
    func fetchFriendList() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        DatabaseManager.shared.getAllFriendsOfUser(with: email) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let friendsData):
                strongSelf.parseToFriends(with: friendsData)
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            case .failure(_):
                self?.friends = []
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    func subLayouts() {
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        // searchBar.becomeFirstResponder()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func screenState(with notEmpty: Bool) {
        if notEmpty {
            tableView.isHidden = false
            noResultsLabel.isHidden = true
        }
        else {
            tableView.isHidden = true
            noResultsLabel.isHidden = false
        }
    }
    
    func openConversation(_ model: UserNode) {
        // open chat space
        var conversationId = ""
        let database = Database.database(url: GeneralSettings.databaseUrl).reference()
        
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: model.email)
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
                
                let vc = MessageChatViewController(with: otherSafeEmail, name: model.firstName + " " + model.lastName, id: conversationId)
                vc.title = model.firstName + " " + model.lastName
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    func openProfilePage(_ model: UserNode) {

    }
    
    func parseToFriends(with listMap: [[String: Any]]) {
        friends = listMap.compactMap{
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
        
        results = friends
    }
    
    @objc func findNewFriend() {
        let vc = FindNewFriendsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc func friendRequest() {
        let vc = FriendRequestViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }

}

// MARK: - Config TableView
extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsCell.identifier, for: indexPath) as! FriendsCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        convertUserNodeToUser(with: self.results[indexPath.row] , completion: { user in
            let vc = OtherUserViewController(otherUser: user)
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let openConversationAction = UIContextualAction(style: .destructive, title: "Chat with") { [weak self] action, view, handler in
            // code
            guard let strongSelf = self else { return }
            
            strongSelf.openConversation(strongSelf.results[indexPath.row])
        }
        // RGB: 6, 214, 159
        openConversationAction.backgroundColor = UIColor(red: 6/255, green: 214/255, blue: 159/255, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [openConversationAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // actions
        let unfriendAction = UIContextualAction(style: .destructive, title: "Unfriend") { [weak self] action, view, handler in
            guard let strongSelf = self else { return }
            
            DatabaseManager.shared.unfriend(with: strongSelf.results[indexPath.row]) { [weak self] result in
                switch result {
                case .success(let isDone):
                    if isDone {
                        // begin delete
                        tableView.beginUpdates()
                        /// Not put 2 line below in closure bc it will crash by startListenConversations will call 2 times.
                        strongSelf.friends.removeAll(where: { $0.id == strongSelf.results[indexPath.row].id })
                        strongSelf.results.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        
                        tableView.endUpdates()
                    }
                    else {
                        print("Failed to delete friend in success case")
                    }
                    break
                case .failure(let error):
                    print("Failed to unfriend with error: \(error)")
                    break
                }
            }
        }
        // RGB: (211, 33, 44)
        // 242 78 30
        unfriendAction.backgroundColor = UIColor(red: 242/255, green: 78/255, blue: 30/255, alpha: 1)
        
        let othersAction = UIContextualAction(style: .destructive, title: "Others") { action, view, handler in
            
        }
        // RGB: (6, 156, 86)
        othersAction.backgroundColor = .systemCyan
        
        
        let configuration = UISwipeActionsConfiguration(actions: [unfriendAction, othersAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: - Config SeachBar
extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            resetFriendList()
            return
        }

//        searchBar.resignFirstResponder()

        spinner.show(in: view)

        searchUser(query: text)

        spinner.dismiss()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        spinner.show(in: view)

        searchUser(query: text)

        spinner.dismiss()
    }

    func searchUser(query: String) {

        filterUsers(with: query)

        // update UI
    }

    func filterUsers(with term: String) {
        // need to test

        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        self.results = self.friends.filter({
                guard let email = ($0.email as? String)?.lowercased(), email != currentUserEmail else {
                    return false
                }

                guard let name = "\($0.firstName.lowercased()) \($0.lastName.lowercased())" as? String else {
                    return false
                }

                return name.hasPrefix(term.lowercased()) || email.hasPrefix(term.lowercased())
            })

        updateUI()
    }

    func updateUI() {
        if friends.isEmpty {
            screenState(with: false)
        } else {
            screenState(with: true)
            tableView.reloadData()
        }
    }
    
    func resetFriendList() {
        self.results = self.friends
        updateUI()
    }
}
