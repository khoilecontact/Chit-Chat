//
//  GroupModel.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 11/05/2022.
//

import Foundation

public struct GroupMessagesCollection {
    let id: String
    let name: String
    let groupId: String
    let latestMessage: LatestMessage
}

public struct Group {
    let id: String
    let name: String
    var members: [UserNode]
    let admin: [String]
    // var conversations: [GroupMessagesCollection]
}
