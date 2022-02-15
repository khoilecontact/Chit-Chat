//
//  MeViewCell.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/02/2022.
//

import Foundation
import UIKit

class MeViewCell: UITableViewCell {
    static let identifier = "MeTableViewCell"
    
    public func setUp(with viewModel: MeViewModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            self.textLabel?.textAlignment = .left
            self.selectionStyle = .none
        case .logout:
            self.textLabel?.textColor = .red
            self.textLabel?.textAlignment = .center
        }
    }
}
