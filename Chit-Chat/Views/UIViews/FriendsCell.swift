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
        imgView.layer.cornerRadius = 35
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
    
    override init(style: FriendsCell.CellStyle, reuseIdentifier: String?) {
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
        
        userImageView.frame = CGRect(x: 10, y: 10,
                                     width: 70, height: 70)
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 20,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: 50)
        userEmailLabel.frame = CGRect(x: userImageView.right + 10,
                                      y: userNameLabel.bottom,
                                      width: contentView.width - 20 - userImageView.width,
                                      height: contentView.height - 10 - userNameLabel.height)
    }
    
    // MARK: - Closure call data
    public func configure(with model: FriendsResult) {
        userNameLabel.text = model.name
        
        let path = "images/\(model.email)_profile_picture.png"
        // call to Storage manager to take img
    }
    
}
