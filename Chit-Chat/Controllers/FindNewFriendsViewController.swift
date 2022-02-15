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
    
    public var completion: ((FriendsResult) -> Void)?
    
    private var users = [[String: Any]]()
    private var hasFetched = false
    
    private var results = [FriendsResult]()
    
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
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
        
        let addAction = UIContextualAction(style: .destructive, title: "Add") { action, view, handler in
            
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
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        spinner.dismiss()
        
        var results: [FriendsResult] = users.filter({
            guard let email = $0["email"], email as! String != safeEmail else {
                return false
            }
            
            guard let name = ($0["name"] as? String)?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else {
                return nil
            }
            
            return FriendsResult(name: name as! String, email: email as! String)
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
