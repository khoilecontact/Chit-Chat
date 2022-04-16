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
            self.selectionStyle = .none
        case .util:
            self.textLabel?.textAlignment = .left
            self.selectionStyle = .none
        }
    }
}
