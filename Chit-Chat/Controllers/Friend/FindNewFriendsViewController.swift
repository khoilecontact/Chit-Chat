//
//  FindNewFriendsViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 08/02/2022.
//

import UIKit
import JGProgressHUD

final class FindNewFriendsViewController: UIViewController {
    
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
        table.isHidden = true
        table.register(NewFriendsViewCell.self, forCellReuseIdentifier: NewFriendsViewCell.identifier)
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
        label.text = "Find New Friends"
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
    
    func sendRequest(with user: UserNode) {
        DatabaseManager.shared.sendFriendRequest(with: user) { [weak self] result in
            guard let strongSelf = self else { return }
            
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
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
                }
                else {
                    print("Failed to send request")
                    break
                }
                
            case .failure(let error):
                print("Failed to send request: \(error)")
            }

        }
    }
    
    func openConversation(_ model: UserNode) {
        // open chat space
        let safeEmail = DatabaseManager.safeEmail(emailAddress: model.email)
        
        let vc = MessageChatViewController(with: safeEmail, id: model.id)
        vc.title = "\(model.firstName) \(model.lastName)"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
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
}

extension FindNewFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewFriendsViewCell.identifier, for: indexPath) as! NewFriendsViewCell
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let openConversationAction = UIContextualAction(style: .destructive, title: "Chat with") { [weak self] action, view, handler in
            
            guard let strongSelf = self else { return }
            
            strongSelf.openConversation(strongSelf.results[indexPath.row])
        }
        openConversationAction.backgroundColor = UIColor(red: 108/255, green: 164/255, blue: 212/255, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [openConversationAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // actions
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, handler in

        }
        deleteAction.backgroundColor = .red
        
        let addAction = UIContextualAction(style: .destructive, title: "Add") { [weak self] action, view, handler in
            guard let strongSelf = self else { return }
            
            strongSelf.sendRequest(with: strongSelf.results[indexPath.row])
        }
        addAction.backgroundColor = .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [addAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}


extension FindNewFriendsViewController: UISearchBarDelegate {
    
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
            // fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
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
        
        let newResults: [UserNode] = users.filter({
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
        })
        
        self.results = newResults
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
