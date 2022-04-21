//
//  Group.swift
//  Chit-Chat
//
//  Created by KhoiLe on 21/04/2022.
//

import Foundation

public struct Group {
    let id: String
    let members: [String]
    let name: String
    let conversations: Conversations
    let createdDate: String
}
