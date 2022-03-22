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
    
    private var friends = [UserNode]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // fakeData()
        
        navigationBar()
        setupSearchBar()
        setupTableView()
        
        // start
        fetchFriendList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func navigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        let findNewFriends = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(findNewFriend))
        let friendRequest = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(friendRequest))
        navigationItem.rightBarButtonItems = [findNewFriends, friendRequest]
    }
    
    func fakeData() {
        // fake data
//        let node = UserNode(id: "hash123",
//                            firstName: "Khoi",
//                            lastName: "Le",
//                            bio: "This is my bio",
//                            email: "uit@gm.uit.edu.vn",
//                            dob: "",
//                            isMale: true)
//        
//        friends.append(node)
        
        // --- ---
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
            case .failure(let error):
                print("Failed to load user's friends: \(error)")
            }
        }
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
    
    func openConversation(_ model: UserNode) {
        // open chat space
        let safeEmail = DatabaseManager.safeEmail(emailAddress: model.email)
        
        let vc = MessageChatViewController(with: safeEmail, id: model.id)
        vc.title = "\(model.firstName) \(model.lastName)"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
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
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsCell.identifier, for: indexPath) as! FriendsCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        convertUserNodeToUser(with: self.friends[indexPath.row] as! UserNode, completion: { user in
                let vc = UIViewController()
                Task.init {
                    do {
                        async let vc = try await OtherUserViewController(otherUser: user)
                    } catch {
                        print("Error in find new friend class")
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let openConversationAction = UIContextualAction(style: .destructive, title: "Chat with") { [weak self] action, view, handler in
            // code
            guard let strongSelf = self else { return }
            
            strongSelf.openConversation(strongSelf.friends[indexPath.row])
        }
        // RGB: 6, 214, 159
        openConversationAction.backgroundColor = UIColor(red: 6/255, green: 214/255, blue: 159/255, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [openConversationAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // actions
        let unfriendAction = UIContextualAction(style: .destructive, title: "Unfriend") { action, view, handler in
            
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
    
}
