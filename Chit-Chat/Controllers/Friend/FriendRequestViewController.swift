//
//  FriendRequestViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 19/02/2022.
//

import UIKit
import JGProgressHUD

class FriendRequestViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    public var completion: ((UserNode) -> Void)?
    
    private var users = [[String: Any]]()
    private var hasFetched = false
    
    private var results = [UserNode]()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Find someone ..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(FriendRequestViewCell.self, forCellReuseIdentifier: FriendRequestViewCell.identifier)
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend Request"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        
        subLayouts()
        
        setupTableView()
        setupSearchBar()
        
        fetchFriendRequest()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.frame = CGRect(x: view.left, y: searchBar.bottom, width: view.width, height: 50)
        tableView.frame = CGRect(x: view.left, y: titleLabel.bottom, width: view.width, height: view.height-50)
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    func navBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
    }
    
    func subLayouts() {
        view.addSubview(titleLabel)
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
    }
    
    func setupTableView() {
        // delegate
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        // searchBar.becomeFirstResponder()
    }
    
    func fetchFriendRequest() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        DatabaseManager.shared.getAllFriendRequestOfUser(with: email) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let requestData):
                strongSelf.hasFetched = true
                strongSelf.users = requestData
                strongSelf.parseToFriendsRequest(with: requestData)
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to load friend request data: \(error)")
            }
        }
    }
    
    func parseToFriendsRequest(with listMap: [[String: Any]]) {
        results = listMap.compactMap{
            guard let id = $0["id"] as? String,
            let email = $0["email"] as? String,
            let lastName = $0["last_name"] as? String,
            let firstName = $0["first_name"] as? String,
            let bio = $0["bio"] as? String?,
            let dob = $0["dob"] as? String?,
            let isMale = $0["is_male"] as? Bool
            else {
                print("excepted type")
                return nil
            }
            
            return UserNode(id: id,
                            firstName: firstName,
                            lastName: lastName,
                            bio: bio ?? "",
                            email: email,
                            dob: dob ?? "",
                            isMale: isMale)
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
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
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
    
    func deniesRequest(with user: UserNode) {
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
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
                    // remove from variable
                    strongSelf.tableView.reloadData()
                }
                else {
                    print("Failed to finish denies request")
                    break
                }
                
            case .failure(let error):
                print("Failed to denies request: \(error)")
            }
        }
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension FriendRequestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestViewCell.identifier, for: indexPath) as! FriendRequestViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
        deleteAction.backgroundColor = .red
        
        let addAction = UIContextualAction(style: .destructive, title: "Accept") { action, view, handler in
            
        }
        addAction.backgroundColor = .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [addAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}


extension FriendRequestViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        searchUser(query: text)
    }
    
    func searchUser(query: String) {
        if hasFetched {
            // filter
            filterUsers(with: query)
        } else {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
            // fetch then filter
            DatabaseManager.shared.getAllFriendRequestOfUser(with: email, completion: { [weak self] result in
                guard let strongSelf = self else {return}
                
                switch result {
                case .success(let userCollection):
                    strongSelf.hasFetched = true
                    strongSelf.users = userCollection
                    strongSelf.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get user: \(error)")
                }
            })
        }
        
        // update UI
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        // let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        spinner.dismiss()
        
        let results: [UserNode] = self.users.filter({
            guard let email = ($0["email"] as? String)?.lowercased(), email != currentUserEmail else {
                return false
            }
            
            guard let name = "\(($0["first_name"] as? String)!.lowercased()) \(($0["last_name"] as? String)!.lowercased())" as? String else {
                return false
            }
            
            return name.hasPrefix(term.lowercased()) || email.hasPrefix(term.lowercased())
        }).compactMap({
            guard let id = $0["id"] as? String,
                  let email = $0["email"] as? String,
                  let lastName = $0["last_name"] as? String,
                  let firstName = $0["first_name"] as? String,
                  let bio = $0["bio"] as? String?,
                  let dob = $0["dob"] as? String?,
                  let isMale = $0["is_male"] as? Bool
            else {
                print("excepted type")
                return nil
            }
            
            return UserNode(id: id,
                            firstName: firstName,
                            lastName: lastName,
                            bio: bio ?? "",
                            email: email,
                            dob: dob ?? "",
                            isMale: isMale)
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
