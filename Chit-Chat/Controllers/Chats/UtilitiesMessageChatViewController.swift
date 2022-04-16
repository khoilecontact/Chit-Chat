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
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UtilitiesMessageChatViewCell.self, forCellReuseIdentifier: UtilitiesMessageChatViewCell.identifier)
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navBar()
        subViews()
        
        setupTableView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func navBar() {
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward")?.withTintColor(UIColor(red: 108/255, green: 164/255, blue: 212/255, alpha: 1), renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backBtnTapped))

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
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return nil
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let filename = safeEmail + "_profile_picture.png"
                let path = "images/" + filename;
                
                let headerView = UIView(frame: CGRect(x: 0, y: 0,
                                                      width: view.width,
                                                      height: 300))
                headerView.backgroundColor = .link
                
                let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 75, width: 150, height: 150))
                
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
    
    func createUtilsModel() {
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .info,
                                                   title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .info,
                                                   title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No email")",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Search message in conversation",
                                                   handler: nil))
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
