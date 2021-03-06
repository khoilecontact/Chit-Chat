//
//  User.swift
//  Chit-Chat
//
//  Created by KhoiLe on 25/01/2022.
//

import Foundation

public struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

struct MessagesCollection {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

public struct User {
    let id: String
    let firstName: String
    let lastName: String
    let bio: String
    let email: String
    let dob: String
    let isMale: Bool
    let province: String
    let district: String
    var friendRequestList: [UserNode]
    var sentfriendRequestList: [UserNode]
    var friendList: [UserNode]
    var blackList: [UserNode]
    var conversations: [MessagesCollection]
    var groupConversations: [GroupMessagesCollection]
    
    var safeEmail: String
    
    var profilePictureFileName: String
    
    init(id: String, firstName: String, lastName: String, email: String, dob: String, isMale: Bool, province: String, district: String) {
        var safeEmailGenerate = email.replacingOccurrences(of: ".", with: ",")
        safeEmailGenerate = safeEmailGenerate.replacingOccurrences(of: "@", with: "-")

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.bio = ""
        self.email = email
        self.dob = dob
        self.isMale = isMale
        self.province = province
        self.district = district
        
        self.friendRequestList = []
        self.sentfriendRequestList = []
        self.friendList = []
        self.blackList = []
        self.conversations = []
        self.groupConversations = []
        self.safeEmail = safeEmailGenerate
        self.profilePictureFileName = { () -> String in
            return "\(safeEmailGenerate)_profile_picture.png"
        }()
    }
    
    init(id: String, firstName: String, lastName: String, bio: String, email: String, dob: String, isMale: Bool, province: String, district: String) {
        var safeEmailGenerate = email.replacingOccurrences(of: ".", with: ",")
        safeEmailGenerate = safeEmailGenerate.replacingOccurrences(of: "@", with: "-")

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.email = email
        self.dob = dob
        self.isMale = isMale
        self.province = province
        self.district = district
        
        self.friendRequestList = []
        self.sentfriendRequestList = []
        self.friendList = []
        self.blackList = []
        self.conversations = []
        self.groupConversations = []
        self.safeEmail = safeEmailGenerate
        self.profilePictureFileName = { () -> String in
            return "\(safeEmailGenerate)_profile_picture.png"
        }()
    }
}
