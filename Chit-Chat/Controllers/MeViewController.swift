//
//  MeViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/02/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

class MeViewController: UIViewController {
    
    var data = [MeViewModel]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MeViewCell.self, forCellReuseIdentifier: MeViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register tableViewCell
        registerTableViewCell()
        // append model
        createProfileModel()
        // add SubViews
        subLayout()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func subLayout() {
        view.addSubview(tableView)
    }
    
    private func registerTableViewCell() {
        tableView.tableHeaderView = createTableHeader()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createProfileModel() {
        data.append(MeViewModel(viewModelType: .info,
                                title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",
                                handler: nil))
        data.append(MeViewModel(viewModelType: .info,
                                title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No email")",
                                handler: nil))
        data.append(MeViewModel(viewModelType: .logout,
                                title: "Log Out",
                                handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let actionAlert = UIAlertController(title: "Do you wanna logout?", message: "Choose Log Out to Logout", preferredStyle: .alert)
            
            actionAlert.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
                strongSelf.signOutFirebase()
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            strongSelf.present(actionAlert, animated: true)
        }))
    }
    
    private func createTableHeader() -> UIView? {
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
}

extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MeViewCell.identifier, for: indexPath) as! MeViewCell
        
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
        
    }
    
    func signOutFirebase() {
        
        // MARK: - Facebook LogOut
        FBSDKLoginKit.LoginManager().logOut()
        // MARK: - Google SignOut
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try? FirebaseAuth.Auth.auth().signOut()
            
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        catch {
            print("Failed to log out")
        }
    }
}
