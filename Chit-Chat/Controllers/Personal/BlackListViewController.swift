//
//  BlackListViewController.swift
//  Chit-Chat
//
//  Created by KhoiLe on 07/04/2022.
//

import Foundation
import UIKit
import JGProgressHUD

class BlackListViewController: UIViewController {
    private var blackList = [UserNode]()
    
    private let tabNumber: Bool = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for blacklist ..."
        return bar
    }()
    
    private let tableView: UITableView = {
        var table = UITableView()
        table.isHidden = false
        table.register(FriendsCell.self, forCellReuseIdentifier: FriendsCell.identifier)
        return table
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Your BlackList is empty"
        label.textColor = UIColor.gray
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Your Black List"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // start
        fetchBlackList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func fetchBlackList() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        self.emptyLabel.removeFromSuperview()
        self.view.addSubview(tableView)
        
        UserAdvancedManager.shared.getAllBlacklistOfUser(with: email) { [weak self] blacklistData in
            guard let strongSelf = self else { return }
            
            self?.blackList = blacklistData
            if !blacklistData.isEmpty {
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            } else {
                self?.tableView.removeFromSuperview()
                
                self?.view.addSubview(self!.emptyLabel)
                self?.emptyLabel.frame = CGRect(x: 90, y: 280, width: 290, height: 290)
            }
        }
    }
    
}

extension BlackListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blackList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = blackList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsCell.identifier, for: indexPath) as! FriendsCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUser = blackList[indexPath.row]
        
        let alert = UIAlertController(title: "\(selectedUser.firstName) \(selectedUser.lastName)", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Unblock", style: .default, handler: { [weak self] (alert: UIAlertAction) in
            let confirmAlert = UIAlertController(title: "Do you want to remove this user from black list?", message: nil, preferredStyle: .actionSheet)
            confirmAlert.addAction(UIAlertAction(title: "Unblock", style: .default, handler: { (alert: UIAlertAction) in
                guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
                let currentSafeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
                
                DatabaseManager.shared.removeFromBlackList(with: currentSafeEmail, otherUser: selectedUser, completion: { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.tableView.reloadData()
                        self?.fetchBlackList()
                        break
                    
                    case .failure(_):
                        let failAlert = UIAlertController(title: "Failed", message: "There has been an error! Please try again later", preferredStyle: .alert)
                        failAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(failAlert, animated: true)
                    }
                })
            }))
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(confirmAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    } 
}
