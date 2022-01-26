//
//  User.swift
//  Chit-Chat
//
//  Created by KhoiLe on 25/01/2022.
//

import Foundation

struct LatestMessage {
    let date: Date
    let text: String
    let isRead: Bool
}

struct MessagesCollection {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct User {
    let id: String
    let firstName: String
    let lastName: String
    let bio: String
    let email: String
    let password: String
    let dob: Date
    let isMale: Bool
    let conversations: [MessagesCollection]
}
