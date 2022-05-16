//
//  CreateGroupViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 16/05/2022.
//

import UIKit
import JGProgressHUD

class CreateGroupViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var peopleInFriendList = [UserNode]()
    private var results = [UserNode]()
    
    public var completion: ((UserNode) -> Void)?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Find someone ..."
        return searchBar
    }()
    
    private let peopleCollection: UICollectionView = {
        let collection = UICollectionView()
        collection.isHidden = true
        collection.register(CreateGroupCollectionViewCell.self, forCellWithReuseIdentifier: CreateGroupCollectionViewCell.identifier)
        return collection
    }()
    
    private let noPeopleInListLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Haven't Friends"
        label.textColor = .green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar()
        
        fakeData()
        
        subViews()
        configCollection()
    }
    
    func navBar() {
        
    }
    
    func configCollection() {
        peopleCollection.delegate = self
        peopleCollection.dataSource = self
    }
    
    func subViews() {
        view.addSubview(searchBar)
        view.addSubview(peopleCollection)
        view.addSubview(noPeopleInListLabel)
    }
    
    func fakeData() {
        
    }
    
}

// helpers
extension CreateGroupViewController {
    func screenState(with notEmpty: Bool) {
        if notEmpty {
            peopleCollection.isHidden = false
            noPeopleInListLabel.isHidden = true
        }
        else {
            peopleCollection.isHidden = true
            noPeopleInListLabel.isHidden = false
        }
    }
    
    func parseToFriends(with listMap: [[String: Any]]) {
        peopleInFriendList = listMap.compactMap{
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
        
        results = peopleInFriendList
    }
}

extension CreateGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peopleInFriendList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupCollectionViewCell.identifier, for: indexPath) as? CreateGroupCollectionViewCell else {
            fatalError("Can't dequeue PersonCell.")
        }
        
        return cell
    }
    
}

// MARK: - Config SeachBar
extension CreateGroupViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            resetFriendList()
            return
        }

//        searchBar.resignFirstResponder()

        spinner.show(in: view)

        searchUser(query: text)

        spinner.dismiss()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        spinner.show(in: view)

        searchUser(query: text)

        spinner.dismiss()
    }

    func searchUser(query: String) {

        filterUsers(with: query)

        // update UI
    }

    func filterUsers(with term: String) {
        // need to test

        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        self.results = self.peopleInFriendList.filter({
                guard let email = ($0.email as? String)?.lowercased(), email != currentUserEmail else {
                    return false
                }

                guard let name = "\($0.firstName.lowercased()) \($0.lastName.lowercased())" as? String else {
                    return false
                }

                return name.hasPrefix(term.lowercased()) || email.hasPrefix(term.lowercased())
            })

        updateUI()
    }

    func updateUI() {
        if peopleInFriendList.isEmpty {
            screenState(with: false)
        } else {
            screenState(with: true)
            // tableView.reloadData()
        }
    }
    
    func resetFriendList() {
        self.results = self.peopleInFriendList
        updateUI()
    }
}
