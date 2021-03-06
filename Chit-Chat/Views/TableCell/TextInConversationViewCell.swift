//
//  TextInConversationViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 27/04/2022.
//

import UIKit

class TextInConversationViewCell: UITableViewCell {

    static var identifier = "TextInConversationViewCell"
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userNameLabel.frame = CGRect(x: contentView.left + 20,
                                     y: 10,
                                     width: contentView.width - 40,
                                     height: (contentView.height - 20)/2)
        
        userMessageLabel.frame = CGRect(x: contentView.left + 20,
                                        y: userNameLabel.bottom + 5,
                                        width: contentView.width - 40,
                                        height: (contentView.height - 20)/2)
    }
    
    // MARK: - Configure Conversations
    public func configure(with model: IMessInConversation) {
        
        userNameLabel.text = "Sender: \(model.sender.first_name) \(model.sender.last_name)"
        userMessageLabel.text = model.message.content
        
        //        let url = URL(string: "https://github.com/khoilecontact.png?size=400")
        //        userImageView.sd_setImage(with: url, completed: nil)
        
        //        let path = "images/\(model.otherUserEmail)_profile_picture.png"
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }

}
