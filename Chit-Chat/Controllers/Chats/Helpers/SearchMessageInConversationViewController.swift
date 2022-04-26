//
//  SearchMessageInConversationViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 26/04/2022.
//

import UIKit
import JGProgressHUD

final class SearchMessageInConversationViewController: UIViewController {
    
    private let data: IMessInConversationResponse? = nil
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No Matched Result"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Search in conversation"

        navBar()
        showInputDialog()
    }
    
    func navBar() {
        navigationItem.hidesBackButton = false
    }
    
    func subViews() {
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
    }
    
    func showInputDialog() {
        let alert = UIAlertController(title: "Enter message", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter your message"
            textField.becomeFirstResponder()
        }
        
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let queryText = textField.text else { return }
            print("text: \(queryText)")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func screenState(with notEmpty: Bool) {
        if notEmpty {
            tableView.isHidden = false
            noResultLabel.isHidden = true
        }
        else {
            tableView.isHidden = true
            noResultLabel.isHidden = false
        }
    }
    

}
