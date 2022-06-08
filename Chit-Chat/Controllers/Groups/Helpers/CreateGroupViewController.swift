//
//  CreateGroupViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 16/05/2022.
//

import UIKit
import JGProgressHUD
import SDWebImage

class CreateGroupViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .light)
    
    private var peopleInFriendList = [UserNode]()
    private var results = [UserNode]()
    private var queueGroupMembers = [UserNode]()
    
    public var completion: ((UserNode) -> Void)?
    
    public var groupName: String = "" {
        didSet {
            groupNameLabel.text = "Name: \(groupName)"
        }
    }
    
    private let circleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your circle"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        let name = UUID().uuidString
        label.text = "Name: " + name[...name.firstIndex(of: "-")!]
        return label
    }()
    
    private let adjustGroupNameBtn: UIButton = {
        let button = UIButton(type: .custom)
        // button.backgroundColor = .red
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.addTarget(self, action: #selector(adjustGroupNameTapped), for: .touchUpInside)
        return button
    }()
    
    private var moreMemberInQueue = 0 {
        didSet {
            suffixQueuedAvatar.text = "+\(moreMemberInQueue)"
        }
    }
    
    private let prefixQueuedAvatar: UIImageView = {
        let img = UIImageView()
        img.image = (UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
        return img
    }()
    
    private let usersSlot1st: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let usersSlot2nd: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let usersSlot3rd: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let usersSlot4th: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let suffixQueuedAvatar: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .gray
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let queuedAvatar: UIView = {
        let view = UIView()
        // view.backgroundColor = .blue
        return view
    }()
    
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let collectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Contacts"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.placeholder = "Find someone ..."
        searchBar.searchTextField.font = .systemFont(ofSize: 14, weight: .regular)
        searchBar.searchTextField.layer.cornerRadius = 18
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        searchBar.layer.borderWidth = 1
        
        return searchBar
    }()
    
    private let peopleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isHidden = true
        collection.register(CreateGroupCollectionViewCell.self, forCellWithReuseIdentifier: CreateGroupCollectionViewCell.identifier)
        return collection
    }()
    
    private let noPeopleInListLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Friends"
        label.textColor = GeneralSettings.primaryColor
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        
        //        fakeData()
        //        screenState(with: true)
        
        subViews()
        configCollection()
        configSearchBar()
        
        // fetch friends of user and update UI
        fetchAllFriendInList()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateSearchBarBorderColorWhenThemeChanged()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleLabel.frame = CGRect(x: 22.5, y: view.top + 110, width: (view.width-40), height: 20)
        circleView.frame = CGRect(x: 20, y: circleLabel.bottom + 10, width: (view.width-40), height: 100)
        
        collectionLabel.frame = CGRect(x: 22.5, y: circleView.bottom + 20, width: (view.width-40), height: 20)
        searchBar.frame = CGRect(x: 10, y: collectionLabel.bottom, width: (view.width-20), height: 60)
        peopleCollection.frame = CGRect(x: 20, y: searchBar.bottom, width: (view.width-40), height: (view.height-340-90))
        noPeopleInListLabel.frame = CGRect(x: 0, y: searchBar.bottom+50, width: view.width, height: 100)
        
        // circleview
        groupNameLabel.frame = CGRect(x: 20, y: 10, width: (circleView.width - 40 - 50), height: 30)
        adjustGroupNameBtn.frame = CGRect(x: circleView.right-20-20-30, y: 10, width: 30, height: 30)
        queuedAvatar.frame = CGRect(x: 20, y: groupNameLabel.bottom + 5, width: (circleView.width - 40), height: (100 - groupNameLabel.height - 20 - 20))
        
        prefixQueuedAvatar.frame = CGRect(x: 0, y: 0, width: 45, height: 40)
        usersSlot1st.frame = CGRect(x: prefixQueuedAvatar.right + 5, y: 0, width: 40, height: 40)
        usersSlot2nd.frame = CGRect(x: usersSlot1st.right - 8, y: 0, width: 40, height: 40)
        usersSlot3rd.frame = CGRect(x: usersSlot2nd.right - 8, y: 0, width: 40, height: 40)
        usersSlot4th.frame = CGRect(x: usersSlot3rd.right - 8, y: 0, width: 40, height: 40)
        suffixQueuedAvatar.frame = CGRect(x: usersSlot4th.right + 8, y: 0, width: 40, height: 40)
    }
    
    func navBar() {
        title = "Create New Group"
        rightButtonBar()
    }
    
    func rightButtonBar() {
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createGroupTapped))
        
        navigationItem.rightBarButtonItem = doneBtn
    }
    
    func configCollection() {
        peopleCollection.delegate = self
        peopleCollection.dataSource = self
    }
    
    func configSearchBar() {
        searchBar.delegate = self
        updateSearchBarBorderColorWhenThemeChanged()
    }
    
    func updateSearchBarBorderColorWhenThemeChanged() {
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    func subViews() {
        view.addSubview(circleLabel)
        view.addSubview(circleView)
        view.addSubview(collectionLabel)
        view.addSubview(searchBar)
        view.addSubview(peopleCollection)
        view.addSubview(noPeopleInListLabel)
        circleSubViews()
    }
    
    func circleSubViews() {
        circleView.addSubview(groupNameLabel)
        circleView.addSubview(adjustGroupNameBtn)
        circleView.addSubview(queuedAvatar)
        queuedAvatar.addSubview(prefixQueuedAvatar)
        queuedAvatar.addSubview(usersSlot1st)
        queuedAvatar.addSubview(usersSlot2nd)
        queuedAvatar.addSubview(usersSlot3rd)
        queuedAvatar.addSubview(usersSlot4th)
        queuedAvatar.addSubview(suffixQueuedAvatar)
    }
    
    func fakeData() {
        results.append(UserNode(id: "id",
                                           firstName: "firstName",
                                           lastName: "lastName",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "19521707@gm.uit.edu.vn",
                                           dob: "",
                                           isMale: true))
        results.append(UserNode(id: "id-2",
                                           firstName: "Phat",
                                           lastName: "Nguyen",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "phatnguyen876@gmail.com",
                                           dob: "",
                                           isMale: true))
        results.append(UserNode(id: "id-2",
                                           firstName: "Phat",
                                           lastName: "T",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "19521707@gm.uit.edu.vn",
                                           dob: "",
                                           isMale: true))
        results.append(UserNode(id: "id-2",
                                           firstName: "Phat",
                                           lastName: "Lee",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "phatnguyen876@gmail.com",
                                           dob: "",
                                           isMale: true))
        results.append(UserNode(id: "id-2",
                                           firstName: "John",
                                           lastName: "Nguyen",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "19521707@gm.uit.edu.vn",
                                           dob: "",
                                           isMale: true))
        results.append(UserNode(id: "id-2",
                                           firstName: "Simon",
                                           lastName: "Nguyen",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "phatnguyen876@gmail.com",
                                           dob: "",
                                           isMale: true))
    }
    
    func fetchAllFriendInList() {
        
        guard let myUnsafeEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        spinner.show(in: view)
        DatabaseManager.shared.getAllFriendsOfUser(with: myUnsafeEmail) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let friendsData):
                strongSelf.parseToFriends(with: friendsData)
                DispatchQueue.main.async {
                    strongSelf.peopleCollection.reloadData()
                    strongSelf.spinner.dismiss()
                    strongSelf.updateUI()
                }
            case .failure(let error):
                self?.peopleInFriendList = []
                DispatchQueue.main.async {
                    strongSelf.peopleCollection.reloadData()
                    strongSelf.spinner.dismiss()
                }
                print("Failed to load friends of user: \(error)")
            }
        }
    }
    
    func loadAvatarToQueue(with model: UserNode) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: model.email)
        
        let path = "images/\(safeEmail)_profile_picture.png"
        // call to Storage manager to take img
        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    switch strongSelf.queueGroupMembers.count {
                    case 1:
                        strongSelf.usersSlot1st.isHidden = false
                        strongSelf.usersSlot1st.sd_setImage(with: url)
                        break
                    case 2:
                        strongSelf.usersSlot2nd.isHidden = false
                        strongSelf.usersSlot2nd.sd_setImage(with: url)
                        break
                    case 3:
                        strongSelf.usersSlot3rd.isHidden = false
                        strongSelf.usersSlot3rd.sd_setImage(with: url)
                        break
                    case 4:
                        strongSelf.usersSlot4th.isHidden = false
                        strongSelf.usersSlot4th.sd_setImage(with: url)
                        break
                    default:
                        print("Out of range")
                    }
                }
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
    }
    
    public func updateAddedStatus(_ isAdded: Bool, senderTag: Int) {
        // find tag and update status
        let cell = (peopleCollection.cellForItem(at: IndexPath(item: senderTag, section: 0) ) as! CreateGroupCollectionViewCell)
        
        if isAdded {
            cell.addedToGroupBtn.isHidden = false
            cell.addToGroupBtn.isHidden = true
        }
        else {
            cell.addedToGroupBtn.isHidden = true
            cell.addToGroupBtn.isHidden = false
        }
    }
    
    @objc func addMemberToGroup(sender: UIButton) {
        print("People in collection: \(sender.tag)")
        
        let newPerson = results[sender.tag]
        
        queueGroupMembers.append(newPerson)
        
        updateAddedStatus(true, senderTag: sender.tag)
        
        // ---
        //                for cell in peopleCollection.visibleCells {
        //                    let indexPath = peopleCollection.indexPath(for: cell)
        //                    print((cell as! CreateGroupCollectionViewCell).userNameLabel.text)
        //                    print((peopleCollection.cellForItem(at: indexPath!) as! CreateGroupCollectionViewCell).userNameLabel.text)
        //                    print(indexPath)
        //                    print(indexPath?.row)
        //                    print(indexPath?.section)
        //                    print(indexPath?.item)
        //
        //                }
        // ---
        
        switch queueGroupMembers.count {
        case let people where people <= 4:
            loadAvatarToQueue(with: newPerson)
        case let people where people > 4:
            moreMemberInQueue = queueGroupMembers.count - 4
            suffixQueuedAvatar.isHidden = false
            break
        default:
            print("Out of range")
        }
        
    }
    
    @objc func removeMemberFromGroup(sender: UIButton) {
        print("People in collection: \(sender.tag)")
        
        let newPerson = results[sender.tag]
        
        queueGroupMembers.removeAll(where: { $0.email == newPerson.email })
        
        updateAddedStatus(false, senderTag: sender.tag)
    }
    
    @objc func adjustGroupNameTapped() {
        let alert = UIAlertController(title: "Insert your group name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Group Name"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            let textField = alert.textFields![0]
            
            strongSelf.groupName = textField.text!
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func createGroupTapped() {
        // create group api
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

extension CreateGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupCollectionViewCell.identifier, for: indexPath) as? CreateGroupCollectionViewCell else {
            fatalError("Can't dequeue PersonCell.")
        }

        cell.configure(with: results[indexPath.item])
        
        // Setup Add Button
        cell.addToGroupBtn.tag = indexPath.item
        cell.addedToGroupBtn.tag = indexPath.item
        cell.addToGroupBtn.addTarget(self, action: #selector(addMemberToGroup), for: .touchUpInside)
        cell.addedToGroupBtn.addTarget(self, action: #selector(removeMemberFromGroup), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.width - 50)/2, height: (view.width - 50) * 0.8/2)
    }
    
}

// MARK: - Config SeachBar
extension CreateGroupViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            resetFriendList()
            return
        }
        
        searchUser(query: text)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchUser(query: text)
        
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
            resetUI()
        }
    }
    
    func resetUI() {
        peopleCollection.reloadData()
        peopleCollection.performBatchUpdates(nil, completion: {
            result in
            self.resetAddBtn()
        })
    }
    
    func resetAddBtn() {
        // refresh data after reset search results
        print(peopleCollection.visibleCells)
        // loop throw all CollectionCell
        for cell in peopleCollection.visibleCells {
            // the queue need to notEmpty, if not /stop/
            guard !queueGroupMembers.isEmpty else { return }
            
            // renew array addBtn status
            (cell as! CreateGroupCollectionViewCell).addToGroupBtn.isHidden = false
            (cell as! CreateGroupCollectionViewCell).addedToGroupBtn.isHidden = true
            
            // loop over the queue and switch addBtn status node's cell
            if queueGroupMembers.contains(where: { $0.email == (cell as! CreateGroupCollectionViewCell).userInfoLabel.text! }) {
                // switch addBtn status
                (cell as! CreateGroupCollectionViewCell).addToGroupBtn.isHidden = true
                (cell as! CreateGroupCollectionViewCell).addedToGroupBtn.isHidden = false
            }
        }
    }
    
    func resetFriendList() {
        self.results = self.peopleInFriendList
        resetUI()
    }
}
