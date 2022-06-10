//
//  ChatsViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/02/2022.
//

import Foundation
import UIKit

final class ChatsViewCell: UITableViewCell {
    static var identifier = "ChatsCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 20,
                                     y: (contentView.height)/2 - 30,
                                     width: 60,
                                     height: 60)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 20,
                                     y: 20,
                                     width: contentView.width - 20 - 20 - userImageView.width,
                                     height: (contentView.height - 40)/2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 20,
                                        y: userNameLabel.bottom + 5,
                                        width: contentView.width - 20 - 20 - userImageView.width,
                                        height: (contentView.height - 40)/2)
    }
    
    // MARK: - Configure Conversations
    public func configure(with model: MessagesCollection) {
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessage.text
        
        // Bold lastest message if is not red
//        if !model.latestMessage.isRead {
//            userMessageLabel.font = UIFont.boldSystemFont(ofSize: 22)
//        }
//        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
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
