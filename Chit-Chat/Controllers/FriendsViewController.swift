//
//  FriendsViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 03/02/2022.
//

import UIKit
import JGProgressHUD

class FriendsViewController: UIViewController {
    
    private var users = [User]()
    
    private let tabNumber: Bool = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Seach for someone ..."
        return bar
    }()
    
    private let tableView: UITableView = {
        var table = UITableView()
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
    }
    
}
