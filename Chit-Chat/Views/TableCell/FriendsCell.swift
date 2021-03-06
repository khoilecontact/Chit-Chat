//
//  FriendsCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 04/02/2022.
//

import Foundation
import UIKit
import SDWebImage

class FriendsCell: UITableViewCell {
    
    static let identifier = "FriendsCell"
    
    private let userImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 30
        imgView.layer.masksToBounds = false
        imgView.clipsToBounds = true
        
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
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Shadow
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.masksToBounds = false
        
        userImageView.frame = CGRect(x: 10,
                                     y: 15,
                                     width: 60,
                                     height: 60)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 20,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20)/2)
        
        userEmailLabel.frame = CGRect(x: userImageView.right + 20,
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
