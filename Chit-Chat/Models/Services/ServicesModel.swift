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

struct IMessInConversationResponse: Codable {
    let result: [IMessInConversation]
    let total: Int
    let page: Int
}

struct IMessInConversation: Codable, Hashable {
    let position: Int
    let sender: ISender
    let message: IMess
}

struct ISender: Codable, Hashable {
    // extends from UserNode by key
    let id: String
    let first_name: String
    let last_name: String
    let province: String
    let district: String
    let bio: String
    let email: String
    let dob: String
    let is_male: Bool
}

struct IToken: Codable, Hashable {
    let token: String
}
