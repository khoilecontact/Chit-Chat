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
    
    public var completion: ((UserNode) -> Void)?
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    public let userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    public let addToGroupBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 15
        button.backgroundColor = .black
        button.isHidden = false
        return button
    }()
    
    public let addedToGroupBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Added", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 15
        button.backgroundColor = .white
        button.isHidden = true
        return button
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemBackground
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = CGFloat(GeneralSettings.borderRadiusButton)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userInfoLabel)
        contentView.addSubview(addToGroupBtn)
        contentView.addSubview(addedToGroupBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 20,
                                     y: 20,
                                     width: 50,
                                     height: 50)
        
        addToGroupBtn.frame = CGRect(x: contentView.right - 20 - 60, y: (20 + (userImageView.height/2) - 15), width: 60, height: 30)
        
        addedToGroupBtn.frame = CGRect(x: contentView.right - 20 - 60, y: (20 + (userImageView.height/2) - 15), width: 60, height: 30)
        
        userNameLabel.frame = CGRect(x: 20,
                                     y: userImageView.bottom + 15,
                                     width: contentView.width - 40,
                                     height: (contentView.height - 40 - 20 - (userImageView.height))/2)
        
        userInfoLabel.frame = CGRect(x: 20,
                                     y: userNameLabel.bottom + 5,
                                     width: contentView.width - 40,
                                     height: (contentView.height - 40 - 20 - (userImageView.height))/2)
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
}
