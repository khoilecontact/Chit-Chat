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
    public static var shared = CreateGroupViewController()
    
    private let spinner = JGProgressHUD(style: .light)
    
    private var peopleInFriendList = [UserNode]()
    private var results = [UserNode]()
    private var groupMembers = [UserNode]()
    
    public var completion: ((UserNode) -> Void)?
    
    public var groupName: String = "" {
        didSet {
            groupNameLabel.text = "Name: \(groupName)"
        }
    }
    
    private let circleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your circle"
        return label
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        let name = UUID().uuidString
        label.text = "Name: " + name[...name.firstIndex(of: "-")!]
        return label
    }()
    
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
        // imageView.image = (UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
        return imageView
    }()
    
    private let usersSlot2nd: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        // imageView.image = (UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
        return imageView
    }()
    
    private let usersSlot3rd: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        // imageView.image = ()
        return imageView
    }()
    
    //    private let avatarStack: UIStackView = {
    //        let stackView = UIStackView()
    //        stackView.axis = .horizontal
    //        stackView.distribution = .equalCentering
    //        stackView.alignment = .center
    //        stackView.spacing = 0
    //        stackView.backgroundColor = .red
    //        return stackView
    //    }()
    
    private let queuedAvatar: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
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
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.placeholder = "Find someone ..."
        searchBar.searchTextField.layer.cornerRadius = 22
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        searchBar.layer.borderColor = Appearance.system.cgColor
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
        label.text = "Haven't Friends"
        label.textColor = .green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar()
        
        fakeData()
        
        subViews()
        configCollection()
        screenState(with: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleLabel.frame = CGRect(x: 20, y: view.top + 100, width: (view.width-40), height: 20)
        circleView.frame = CGRect(x: 20, y: circleLabel.bottom + 10, width: (view.width-40), height: 100)
        collectionLabel.frame = CGRect(x: 20, y: circleView.bottom + 40, width: (view.width-40), height: 20)
        //        searchBar.frame = CGRect(x: 20, y: collectionLabel.bottom + 20, width: (view.width-40), height: 30)
        searchBar.frame = CGRect(x: 10, y: collectionLabel.bottom, width: (view.width-20), height: 70)
        peopleCollection.frame = CGRect(x: 20, y: searchBar.bottom, width: (view.width-40), height: (view.height-100))
        noPeopleInListLabel.frame = CGRect(x: 20, y: (view.height-100)/2, width: view.width-20, height: 100)
        
        // circleview
        groupNameLabel.frame = CGRect(x: 20, y: 10, width: (circleView.width - 40 - 40), height: 20)
        // avatarStack.frame = CGRect(x: 20, y: groupNameLabel.bottom + 20, width: (circleView.width - 200), height: (100 - groupNameLabel.height - 20 - 20))
        queuedAvatar.frame = CGRect(x: 20, y: groupNameLabel.bottom + 20, width: (circleView.width - 40), height: (100 - groupNameLabel.height - 20 - 20))
        
        prefixQueuedAvatar.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        usersSlot1st.frame = CGRect(x: prefixQueuedAvatar.right + 5, y: 0, width: 40, height: 40)
        usersSlot2nd.frame = CGRect(x: usersSlot1st.right, y: 0, width: 40, height: 40)
        usersSlot3rd.frame = CGRect(x: usersSlot2nd.right, y: 0, width: 40, height: 40)
        
    }
    
    func navBar() {
        title = "Create New Group"
    }
    
    func configCollection() {
        peopleCollection.delegate = self
        peopleCollection.dataSource = self
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
        circleView.addSubview(queuedAvatar)
        queuedAvatar.addSubview(prefixQueuedAvatar)
        queuedAvatar.addSubview(usersSlot1st)
        queuedAvatar.addSubview(usersSlot2nd)
        queuedAvatar.addSubview(usersSlot3rd)
        
    }
    
    func fakeData() {
        peopleInFriendList.append(UserNode(id: "id",
                                           firstName: "firstName",
                                           lastName: "lastName",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "19521707@gm.uit.edu.vn",
                                           dob: "",
                                           isMale: true))
        peopleInFriendList.append(UserNode(id: "id-2",
                                           firstName: "Phat",
                                           lastName: "Nguyen",
                                           province: "province",
                                           district: "district",
                                           bio: "",
                                           email: "19521707@gm.uit.edu.vn",
                                           dob: "",
                                           isMale: true))
    }
    
    func fetchAllFriendInList() {
        
        guard let myUnsafeEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        DatabaseManager.shared.getAllFriendsOfUser(with: myUnsafeEmail) { [weak self] result in
            guard let strongSelf = self else { return }
            
            
        }
    }
    
    public func addPersonToGroup() {
        // with newPerson: UserNode
        /**
         * Check members.count:
         * - case 1: add to array
         * - case 2: add to array x2
         * - case 3: add 3 people
         * - case 4: add x3 and show +(members.count - 3)
         */
//        groupMembers.append(newPerson)
//
//        if (groupMembers.count > 3) {
//
//        }
        
//        for user in peopleInFriendList {
//            let user =
//            user.frame = CGRect(x: prefixQueuedAvatar.right + 5, y: 0, width: 40, height: 40)
//            queuedAvatar.addSubview(user)
//            user.sd_setImage(with: URL(string: "https://avatars.githubusercontent.com/u/69576826?v=4"))
//        }
        
//        usersSlot1st.sd_setImage(with: URL(string: "https://img5.thuthuatphanmem.vn/uploads/2021/12/08/anh-nen-anime-dep-yen-tinh_101044752.jpg"), placeholderImage: UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal), options: .refreshCached)
//        usersSlot2nd.sd_setImage(with: URL(string: "https://img5.thuthuatphanmem.vn/uploads/2021/12/08/anh-nen-anime-dep-yen-tinh_101044752.jpg"), placeholderImage: UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal), options: .refreshCached)
//        usersSlot3rd.sd_setImage(with: URL(string: "https://img5.thuthuatphanmem.vn/uploads/2021/12/08/anh-nen-anime-dep-yen-tinh_101044752.jpg"), placeholderImage: UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal), options: .refreshCached)
    
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
        return peopleInFriendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupCollectionViewCell.identifier, for: indexPath) as? CreateGroupCollectionViewCell else {
            fatalError("Can't dequeue PersonCell.")
        }

        cell.configure(with: peopleInFriendList[indexPath.item])
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
