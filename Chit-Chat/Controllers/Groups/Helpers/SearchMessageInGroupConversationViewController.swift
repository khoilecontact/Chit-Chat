//
//  SearchMessageInGroupConversationViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 09/06/2022.
//

import UIKit
import JGProgressHUD
import Toast_Swift

final class SearchMessageInGroupConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var data: IMessInConversationResponse? = nil
    
    public let groupId: String
    public let groupName: String
    private var conversationId: String
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TextInConversationViewCell.self, forCellReuseIdentifier: TextInConversationViewCell.identifier)
        table.rowHeight = 80
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
    
    init(groupId: String, name: String, conversationId: String) {
        self.conversationId = conversationId
        self.groupName = name
        self.groupId = groupId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Search in conversation"

        navBar()
        subViews()
        tableDelegate()
        showInputDialog()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: 10,
                                           y: (view.height-100)/2,
                                           width: view.width-20,
                                           height: 100)
    }
    
    func navBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
    }
    
    func subViews() {
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
    }
    
    func tableDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func showInputDialog() {
        let alert = UIAlertController(title: "Enter message", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter your message"
            textField.becomeFirstResponder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            self.dismissSelf()
        }
        alert.addAction(cancelAction)
        
        alert.addAction(UIAlertAction(title: "Find", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let queryText = textField.text else { return }
            guard queryText != "" else {
                self.view.makeToast("Please input message")
                return self.showInputDialog()
            }
            self.fetchTextInConversation(query: queryText)
            // self.showConversation()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchTextInConversation(query: String) {
        
        self.spinner.show(in: view)
        
        Task {
            
            do {
                
                let textInConversation: IMessInConversationResponse? = try await ServiceManager.shared.findTextInGroupConversation(conversationID: conversationId, query: query)
                
                if textInConversation?.total != 0 {
                    self.spinner.dismiss()
                    // recall to show conversation
                    self.data = textInConversation
                    self.screenState(with: true)
                    self.configureTableView(query: query, total: textInConversation!.total)
                }
                else {
                    self.screenState(with: false)
                }
                
                self.spinner.dismiss()
                
            } catch {
                self.spinner.dismiss()
                self.screenState(with: false)
                print("Request failed with error: \(error)")
            }
            
        }
    }
    
    func createTableHeader(query: String, total: Int) -> UIView? {
        
        title = "Result for \"\(query)\""
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0,
                                              width: view.width,
                                              height: 48))
        headerView.backgroundColor = GeneralSettings.primaryColor
        
        let totalView = UILabel(frame: CGRect(x: headerView.left+20, y: 10, width: headerView.width - 20, height: 30))
        totalView.text = (total > 1) ? "\(total) messages" : "\(total) message"
        
        headerView.addSubview(totalView)
        
        return headerView
    }
    
    func showInConversation(position: Int?) {
        let vc = GroupChatViewController(with: conversationId, groupid: groupId, name: groupName, messagePosition: position)
        vc.title = groupName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureTableView(query: String, total: Int) {
        tableView.tableHeaderView = createTableHeader(query: query, total: total)
        tableView.reloadData()
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
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchMessageInGroupConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.total ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model: IMessInConversation = (data?.result[indexPath.row])!
        let cell = tableView.dequeueReusableCell(withIdentifier: TextInConversationViewCell.identifier, for: indexPath) as! TextInConversationViewCell
        // config cell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showInConversation(position: data?.result[indexPath.row].position)
    }
}
