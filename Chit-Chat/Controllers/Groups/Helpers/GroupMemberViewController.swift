//
//  GroupMemberViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 09/06/2022.
//

import UIKit
import JGProgressHUD

class GroupMemberViewController: UIViewController {

    private var groupMembers = [UserNode]()
    private var groupId: String
    
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
        table.register(GroupMemberViewCell.self, forCellReuseIdentifier: GroupMemberViewCell.identifier)
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
    
    init(with groupId: String) {
        self.groupId = groupId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Group Members"
        view.backgroundColor = .systemBackground
        
        // fakeData()
        fetchAllGroupMembers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // start
        // fetchFriendList()
        navigationBar()
        subLayouts()
        setupTableView()
        
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
        // navigationController?.navigationBar.topItem?.titleView = searchBar
        
    }
    
    func subLayouts() {
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
    }
    
    func fetchAllGroupMembers() {
        DatabaseManager.shared.getAllGroupMembers(with: groupId) { [weak self] result in
            switch result {
            case .success(let memberList):
                self?.groupMembers = memberList
                break
            case .failure(let error):
                print("Failed to fetch members: \(error)")
                break
            }
        }
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
    
    func openProfilePage(_ model: UserNode) {

    }

}

// MARK: - Config TableView
extension GroupMemberViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = groupMembers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberViewCell.identifier, for: indexPath) as! GroupMemberViewCell
        cell.configure(with: model)
        
        // Hide divider in talbe
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        convertUserNodeToUser(with: self.groupMembers[indexPath.row] , completion: { user in
            let vc = OtherUserViewController(otherUser: user)
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let openConversationAction = UIContextualAction(style: .destructive, title: "Profile") { action, view, handler in
            // code
            // guard let strongSelf = self else { return }
            
            // strongSelf.openConversation(strongSelf.results[indexPath.row])
        }
        // RGB: 6, 214, 159
        openConversationAction.backgroundColor = UIColor(red: 6/255, green: 214/255, blue: 159/255, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [openConversationAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}

// MARK: - Config SeachBar
//extension GroupMemberViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
//            resetFriendList()
//            return
//        }
//
//        searchUser(query: text)
//
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
//            return
//        }
//
//        searchBar.resignFirstResponder()
//
//        searchUser(query: text)
//
//    }
//
//    func searchUser(query: String) {
//
//        filterUsers(with: query)
//
//        // update UI
//    }
//
//    func filterUsers(with term: String) {
//        // need to test
//
//        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
//            return
//        }
//
//        self.results = self.friends.filter({
//                guard let email = ($0.email as? String)?.lowercased(), email != currentUserEmail else {
//                    return false
//                }
//
//                guard let name = "\($0.firstName.lowercased()) \($0.lastName.lowercased())" as? String else {
//                    return false
//                }
//
//                return name.hasPrefix(term.lowercased()) || email.hasPrefix(term.lowercased())
//            })
//
//        updateUI()
//    }
//
//    func updateUI() {
//        if friends.isEmpty {
//            screenState(with: false)
//        } else {
//            screenState(with: true)
//            tableView.reloadData()
//        }
//    }
//
//    func resetFriendList() {
//        self.results = self.friends
//        updateUI()
//    }
//}
//
