//
//  GroupUtilitiesChatViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/05/2022.
//

import UIKit

class GroupUtilitiesChatViewController: UIViewController {

    var utils = [UtilitiesMessageChatViewModel]()
    var groupName: String
    var groupId: String
    var conversationId: String
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorColor = .systemBackground
        table.register(GroupUtilitiesMessageChatViewCell.self, forCellReuseIdentifier: GroupUtilitiesMessageChatViewCell.identifier)
        return table
    }()
    
    init(name: String, groupId: String, conversationId: String) {
        self.groupName = name
        self.groupId = groupId
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navBar()
        subViews()
        
        createUtilOptions()
        setupTableView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func navBar() {
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward")?.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backBtnTapped))

        navigationItem.leftBarButtonItem = backItem
    }
    
    func setupTableView() {
        tableView.tableHeaderView = createTableHeader()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func subViews() {
        view.addSubview(tableView)
    }
    
    func createTableHeader() -> UIView? {
        
        //        let safeEmail = DatabaseManager.safeEmail(emailAddress: otherEmail)
        let filename = "\(groupId)_group_picture.png"
        let path = "group_images/" + filename;
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0,
                                              width: view.width,
                                              height: 100))
        headerView.backgroundColor = .systemBackground
                
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-80)/2, y: (headerView.height-80)/2, width: 80, height: 80))
                
        // styles
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url with error: \(error)")
            }
        })
        
        return headerView
    }
    
    func createUtilOptions() {
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .info,
                                                   title: "\(groupName)",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Members",
                                                   handler: nil))
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .pending,
        //                                                   title: "Reminder",
        //                                                   handler: nil))
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .pending,
        //                                                   title: "Assign Task",
        //                                                   handler: nil))
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .pending,
        //                                                   title: "Git",
        //                                                   handler: nil))
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .pending,
        //                                                   title: "Todo List",
        //                                                   handler: nil))
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
        //                                                   title: "Add member",
        //                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Search message in conversation",
                                                   handler: { [weak self] in
            guard let strongSelf = self else { return }
            
            let vc = SearchMessageInGroupConversationViewController(groupId: strongSelf.groupId, name: strongSelf.groupName, conversationId: strongSelf.conversationId)
            let nav = UINavigationController(rootViewController: vc)
            self?.present(nav, animated: true)
            
        }))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Notification",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Report",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .dangerous,
                                                   title: "Delete group",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .dangerous,
                                                   title: "Leave group",
                                                   handler: nil))
    }
    
    @objc func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension GroupUtilitiesChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return utils.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = utils[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupUtilitiesMessageChatViewCell.identifier, for: indexPath) as! GroupUtilitiesMessageChatViewCell
        
        cell.createTableCellValue(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        utils[indexPath.row].handler?()
    }
}
