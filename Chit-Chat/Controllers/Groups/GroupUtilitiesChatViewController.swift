//
//  GroupUtilitiesChatViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/05/2022.
//

import UIKit
import JGProgressHUD
import Toast_Swift

class GroupUtilitiesChatViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

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
                
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-80)/2, y: (headerView.height-80)/2 + 10, width: 80, height: 80))
                
        // styles
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeGroupPictureTapped)))
        imageView.isUserInteractionEnabled = true
        
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
                                                   handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let alert = UIAlertController(title: "Insert your group name", message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Group Name"
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                
                let textField = alert.textFields![0]
                
                guard let newName = textField.text, !newName.isEmpty else {
                    strongSelf.view.makeToast("Group name must not be empty")
                    return
                }
                
                // update group name func
                DatabaseManager.shared.updateGroupName(with: newName, groupId: strongSelf.groupId) { result in
                    switch result {
                    case .success(let newReturnedName):
                        strongSelf.navigationController?.popToRootViewController(animated: true)
                        break
                    case .failure(let error):
                        print("Failed to update group name with error: \(error)")
                        break
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true, completion: nil)
        }))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Members",
                                                   handler: { [weak self] in
            guard let strongSelf = self else { return }
            
            let vc = GroupMemberViewController(with: strongSelf.groupId)
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        }))
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
        //        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
        //                                                   title: "Notification",
        //                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .util,
                                                   title: "Report",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .dangerous,
                                                   title: "Delete group",
                                                   handler: nil))
        utils.append(UtilitiesMessageChatViewModel(viewModelType: .dangerous,
                                                   title: "Leave group",
                                                   handler: { [weak self] in
            guard let strongSelf = self, let unSafeEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                print("Email or self is empty")
                return
            }
            
            strongSelf.spinner.show(in: strongSelf.view)
            
            DatabaseManager.shared.leaveGroup(with: unSafeEmail, groupId: strongSelf.groupId, completion: { success in
                if success {
                    DispatchQueue.main.async {
                        strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
            })
            
            
            
        }))
    }
    
    @objc func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func changeGroupPictureTapped() {
        
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach photo from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            strongSelf.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            strongSelf.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
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

extension GroupUtilitiesChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            let fileName = "\(groupId)_group_picture.png"
            
            // upload Image
            StorageManager.shared.uploadGroupPicture(with: imageData, fileName: fileName, completion: { [weak self] result in
                switch result {
                case .success(let downloadUrl):
                    self?.view.makeToast("Upload successfully")
                    self?.tableView.tableHeaderView = self?.createTableHeader()
                case .failure(let error):
                    self?.view.makeToast("Failed to upload group picture")
                    print("Failed to upload with error: \(error)")
                }
            })
            // ---
        }
        
    }
}
