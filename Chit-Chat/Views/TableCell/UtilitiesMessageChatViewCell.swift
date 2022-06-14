//
//  UtilitiesMessageChatViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 16/04/2022.
//

import Foundation
import UIKit

final class UtilitiesMessageChatViewCell: UITableViewCell {
    static let identifier = "UtilitiesMessageChatViewCell"
    
    public func createTableCellValue(with model: UtilitiesMessageChatViewModel) {
        // @deprecated in next version
        self.textLabel?.text = model.title
        typeofViewModel(with: model)
    }
    
    private func typeofViewModel(with model: UtilitiesMessageChatViewModel) {
        switch model.viewModelType {
        case .info:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            self.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            self.selectionStyle = .none
        case .subinfo:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            self.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            self.selectionStyle = .none
        case .empty:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            self.selectionStyle = .none
        case .pending:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .gray
            self.selectionStyle = .none
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
        case .util:
            self.textLabel?.textAlignment = .left
            // self.selectionStyle = .none
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
        case .dangerous:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .red
            // self.selectionStyle = .none
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
        case .back:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = .red
            self.textLabel?.font = .preferredFont(forTextStyle: .title2)
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
            self.selectionStyle = .default
        }
    }
}

final class GroupUtilitiesMessageChatViewCell: UITableViewCell {
    static let identifier = "GroupUtilitiesMessageChatViewCell"
    
    public func createTableCellValue(with model: UtilitiesMessageChatViewModel) {
        // @deprecated in next version
        self.textLabel?.text = model.title
        typeofViewModel(with: model)
    }
    
    private func typeofViewModel(with model: UtilitiesMessageChatViewModel) {
        switch model.viewModelType {
        case .info:
            //            let attachment = NSTextAttachment.init()
            //            attachment.image = UIImage(systemName: "scribble")?.withTintColor(.link, renderingMode: .alwaysOriginal)
            //            let attachmentString = NSAttributedString(attachment: attachment)
            
            //            let attachment2 = NSTextAttachment.init()
            //            attachment2.image = UIImage(systemName: "pencil")?.withTintColor(.link, renderingMode: .alwaysOriginal)
            //            let attachmentString2 = NSAttributedString(attachment: attachment2)
            //
            //            let completeString = NSMutableAttributedString(string: model.title + "  ")
            //            // completeString.append(attachmentString)
            //            completeString.append(attachmentString2)
            
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.selectionStyle = .none
            self.textLabel?.font = .systemFont(ofSize: 24, weight: .bold)
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            // self.textLabel?.attributedText = completeString
            
        case .subinfo:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            self.textLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
            self.selectionStyle = .none
            
        case .empty:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            // self.sizeThatFits(CGSize(width: contentView.width, height: 50))
            self.selectionStyle = .none
            
        case .pending:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .gray
            self.selectionStyle = .none
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
        case .util:
            self.textLabel?.textAlignment = .left
            // self.selectionStyle = .none
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
        case .dangerous:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .red
            // self.selectionStyle = .none
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
        case .back:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = .red
            self.textLabel?.font = .preferredFont(forTextStyle: .title2)
            self.imageView!.image = UIImage(systemName: model.icon!)!.withTintColor(GeneralSettings.primaryColor, renderingMode: .alwaysOriginal)
            self.selectionStyle = .default
        }
    }
}
