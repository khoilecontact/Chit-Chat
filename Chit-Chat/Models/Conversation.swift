//
//  Conversation.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 26/01/2022.
//

import Foundation

struct Conversations {
    let messages: [MessageOfConversation]
}

struct MessageOfConversation {
    let id: String
    let type: String    // messages type
    let content: String
    let date: Date
    let sender_email: String
    let name: String
    let is_read: Bool = false
}
