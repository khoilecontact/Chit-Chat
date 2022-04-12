//
//  ServicesModel.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 12/04/2022.
//

import Foundation

struct IConversation: Codable {
    let messages: [IMess]
}

struct IMess: Codable, Hashable {
    let content: String
    let date: String
    let id: String
    let is_read: Bool
    let name: String
    let sender_email: String
    let type: String
}
