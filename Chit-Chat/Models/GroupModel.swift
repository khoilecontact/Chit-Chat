//
//  GroupModel.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/05/2022.
//

import Foundation

struct GroupMessagesCollection {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

public struct Group {
    let id: String
    let name: String
    var members: [String]
    var conversations: [GroupMessagesCollection]
}
