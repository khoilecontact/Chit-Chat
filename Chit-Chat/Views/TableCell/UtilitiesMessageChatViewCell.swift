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
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .link
            self.selectionStyle = .none
        case .pending:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .gray
            self.selectionStyle = .none
        case .util:
            self.textLabel?.textAlignment = .left
            self.selectionStyle = .none
        case .dangerous:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .red
            self.selectionStyle = .none
        case .back:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = .red
            self.textLabel?.font = .preferredFont(forTextStyle: .title2)
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
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = GeneralSettings.secondaryColor
            self.selectionStyle = .none
            self.textLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        case .pending:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .gray
            self.selectionStyle = .none
        case .util:
            self.textLabel?.textAlignment = .left
            self.selectionStyle = .none
        case .dangerous:
            self.textLabel?.textAlignment = .left
            self.textLabel?.textColor = .red
            self.selectionStyle = .none
        case .back:
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = .red
            self.textLabel?.font = .preferredFont(forTextStyle: .title2)
            self.selectionStyle = .default
        }
    }
}
