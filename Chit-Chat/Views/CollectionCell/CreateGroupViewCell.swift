//
//  CreateGroupCollectionViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 16/05/2022.
//

import Foundation
import UIKit

class CreateGroupCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "CreateGroupViewCell"
    
    public var delegate: GroupActionDelegate?
    
    public var completion: ((UserNode) -> Void)?
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    private let addToGroupBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 15
        button.backgroundColor = .black
        return button
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupAction()
        
        contentView.backgroundColor = .systemBackground
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = CGFloat(GeneralSettings.borderRadiusButton)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userInfoLabel)
        contentView.addSubview(addToGroupBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 20,
                                     y: 10,
                                     width: 50,
                                     height: 50)
        
        addToGroupBtn.frame = CGRect(x: contentView.right - 20 - 60, y: (10 + (userImageView.height/2) - 15), width: 60, height: 30)
        addToGroupBtn.addTarget(self, action: #selector(callback), for: .touchUpInside)
        
        userNameLabel.frame = CGRect(x: 20,
                                     y: userImageView.bottom + 10,
                                     width: contentView.width - 40,
                                     height: (contentView.height - 20 - 15 - (userImageView.height))/2)
        
        userInfoLabel.frame = CGRect(x: 20,
                                     y: userNameLabel.bottom + 5,
                                     width: contentView.width - 40,
                                     height: (contentView.height - 20 - 15 - (userImageView.height))/2)
    }
    
    func setupAction() {
        self.delegate = CreateGroupViewController()
    }
    
    // MARK: - Configure User in List
    public func configure(with model: UserNode) {
        userNameLabel.text = "\(model.firstName) \(model.lastName)"
        userInfoLabel.text = model.email
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: model.email)
        
        let path = "images/\(safeEmail)_profile_picture.png"
        // call to Storage manager to take img
        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    strongSelf.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
    }
    
    @objc func callback() {
        self.delegate?.addMemberToGroup()
    }
}
