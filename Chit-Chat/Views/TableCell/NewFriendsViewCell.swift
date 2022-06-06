//
//  NewFriendsViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 08/02/2022.
//

import Foundation

import Foundation
import UIKit
import SDWebImage

class NewFriendsViewCell: UITableViewCell {
    
    static let identifier = "NewFriendsCell"
    
    private let userImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 40
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userEmailLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = Appearance.system
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        userImageView.frame = CGRect(x: 10,
                                     y: 5,
                                     width: 80,
                                     height: 80)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 25,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20)/2)
        
        userEmailLabel.frame = CGRect(x: userImageView.right + 25,
                                        y: userNameLabel.bottom,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20)/2)
    }
    
    // MARK: - Closure call data
    public func configure(with model: UserNode) {
        userNameLabel.text = "\(model.firstName) \(model.lastName)"
        userEmailLabel.text = model.email
        
        //        let url = URL(string: "https://github.com/khoilecontact.png?size=400")
        //        userImageView.sd_setImage(with: url, completed: nil)
        
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
