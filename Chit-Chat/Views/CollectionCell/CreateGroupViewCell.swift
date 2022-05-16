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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Conversations
    //    public func configure(with model: MessagesCollection) {
    ////        userNameLabel.text = model.name
    ////        userMessageLabel.text = model.latestMessage.text
    //
    //        let path = "images/\(model.otherUserEmail)_profile_picture.png"
    //        // call to Storage manager to take img
    //        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
    //            guard let strongSelf = self else { return }
    //
    //            switch result {
    //            case .success(let url):
    //                DispatchQueue.main.async {
    //                    strongSelf.userImageView.sd_setImage(with: url, completed: nil)
    //                }
    //            case .failure(let error):
    //                print("Failed to get image url: \(error)")
    //            }
    //        }
    //    }
    
}
