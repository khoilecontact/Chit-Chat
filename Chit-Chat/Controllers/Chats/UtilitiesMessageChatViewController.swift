//
//  UtilitiesMessageChatViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 16/04/2022.
//

// Notes- This is setup: Change init -> receive other url avatar and show to the header in createHeader()

import UIKit

class UtilitiesMessageChatViewController: UIViewController  {
    
    var utils = [UtilitiesMessageChatViewModel]()
    var otherName: String
    var otherEmail: String
    var conversationId: String
    
    private let tableView: UITableView = {
        let table = UITableView()
        //        table.separatorColor = .systemBackground
        table.register(UtilitiesMessageChatViewCell.self, forCellReuseIdentifier: UtilitiesMessageChatViewCell.identifier)
        
        return table
    }()
    
    init(name: String, email: String, conversationId: String) {
        self.otherName = name
        self.otherEmail = email
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
        let filename = otherEmail + "_profile_picture.png"
        let path = "images/" + filename;
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0,
                                              width: view.width,
                                              height: 120))
        headerView.backgroundColor = .systemBackground
                
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-100)/2, y: (headerView.height-100)/2, width: 100, height: 100))
                
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
                                                   title: "Name: \(otherName)",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .info,
                                                   title: "Email: \(otherEmail)",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .pending,
                                                   title: "Nicknames -- In Beta, coming soon!",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Create chat group",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Search message in conversation",
                                                   handler: { [weak self] in
            guard let strongSelf = self else { return }
            
            let vc = SearchMessageInConversationViewController(email: strongSelf.otherEmail, name: strongSelf.otherName, conversationId: strongSelf.conversationId)
            let nav = UINavigationController(rootViewController: vc)
            self?.present(nav, animated: true)
            
        }))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .dangerous,
                                                   title: "Block",
                                                   handler: nil))
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .back,
        //                                                   title: "Go Back",
        //                                                   handler: { [weak self] in self?.dismiss(animated: true) }))
    }
    
    @objc func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension UtilitiesMessageChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return utils.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = utils[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UtilitiesMessageChatViewCell.identifier, for: indexPath) as! UtilitiesMessageChatViewCell
        
        cell.createTableCellValue(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        utils[indexPath.row].handler?()
    }
}
