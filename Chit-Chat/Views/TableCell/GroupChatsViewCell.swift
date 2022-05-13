//
//  GroupChatsViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/05/2022.
//

import Foundation
import UIKit

final class GroupChatsViewCell: UITableViewCell {
    static var identifier = "GroupChatsCell"
    
    private let groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let groupMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(groupImageView)
        contentView.addSubview(groupNameLabel)
        contentView.addSubview(groupMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        groupImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 80,
                                     height: 80)
        
        groupNameLabel.frame = CGRect(x: groupImageView.right + 20,
                                     y: 10,
                                     width: contentView.width - 20 - groupImageView.width,
                                     height: (contentView.height - 20)/2)
        
        groupMessageLabel.frame = CGRect(x: groupImageView.right + 20,
                                        y: groupNameLabel.bottom + 10,
                                        width: contentView.width - 20 - groupImageView.width,
                                        height: (contentView.height - 20)/2)
    }
    
    // MARK: - Configure Conversations
    public func configure(with model: GroupMessagesCollection) {
        groupNameLabel.text = model.name
        groupMessageLabel.text = model.latestMessage.text
        
        //        let url = URL(string: "https://github.com/khoilecontact.png?size=400")
        //        groupImageView.sd_setImage(with: url, completed: nil)
        
        let path = "images/\(model.id)_group_picture.png"
        // call to Storage manager to take img
        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    strongSelf.groupImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
    }
}
