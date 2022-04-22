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
        
        DatabaseManager.shared.getBlackListOfUser(with: email) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let blacklistData):
                print(blacklistData)
                strongSelf.parseToFriends(with: blacklistData)
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
                break
            case .failure(_):
                self!.tableView.removeFromSuperview()
                
                self!.view.addSubview(self!.emptyLabel)
                self!.emptyLabel.frame = CGRect(x: 90, y: 280, width: 290, height: 290)
                break
            }
        }
    }
    
    func openConversation(_ model: UserNode) {
        // open chat space
        let safeEmail = DatabaseManager.safeEmail(emailAddress: model.email)
        
        let vc = MessageChatViewController(with: safeEmail, name: "\(model.firstName) \(model.lastName)", id: model.id)
        vc.title = "\(model.firstName) \(model.lastName)"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openProfilePage(_ model: UserNode) {

    }
    
    func parseToFriends(with listMap: [[String: Any]]) {
        blackList = listMap.compactMap{
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
        
        
    } 
}
