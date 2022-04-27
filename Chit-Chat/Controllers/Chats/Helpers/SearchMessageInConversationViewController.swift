//
//  SearchMessageInConversationViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 26/04/2022.
//

import UIKit
import JGProgressHUD

final class SearchMessageInConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var data: IMessInConversationResponse? = nil
    
    public let otherUserEmail: String
    public let otherUserName: String
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
    
    init(email: String, name: String, conversationId: String) {
        self.conversationId = conversationId
        self.otherUserName = name
        self.otherUserEmail = email
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
        
        alert.addAction(UIAlertAction(title: "Find", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let queryText = textField.text else { return }
            self.fetchTextInConversation(query: queryText)
            // self.showConversation()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchTextInConversation(query: String) {
        
        self.spinner.show(in: view)
        
        Task {
            
            do {
                
                let textInConversation: IMessInConversationResponse? = try await ServiceManager.shared.findTextInConversation(conversationID: conversationId, query: query)
                
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
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0,
                                              width: view.width,
                                              height: 120))
        headerView.backgroundColor = .systemBackground
                
        let titleView = UILabel(frame: CGRect(x: (headerView.width-80)/2, y: (headerView.height-80)/2, width: headerView.width - 20, height: 30))
        titleView.text = "Result for \"\(query)\""
        
        let totalView = UILabel(frame: CGRect(x: headerView.left+30, y: titleView.bottom+10, width: headerView.width - 20, height: 30))
        totalView.text = "\(total)"
                
        // styles
        
        headerView.addSubview(titleView)
        headerView.addSubview(totalView)
        
        return headerView
    }
    
    func showInConversation(position: Int?) {
        let vc = MessageChatViewController(with: self.otherUserEmail, name: self.otherUserName, id: self.conversationId, messagePosition: position)
        vc.title = self.otherUserName
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

extension SearchMessageInConversationViewController: UITableViewDelegate, UITableViewDataSource {
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
