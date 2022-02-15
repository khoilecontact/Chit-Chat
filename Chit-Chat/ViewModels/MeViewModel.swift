//
//  MeViewModel.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/02/2022.
//

import Foundation

enum MeViewModelType {
    case info, logout
}

struct MeViewModel {
    let viewModelType: MeViewModelType
    let title: String
    let handler: (() -> Void)?
}
