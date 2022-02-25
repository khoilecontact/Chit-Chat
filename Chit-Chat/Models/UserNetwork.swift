//
//  UserNetwork.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 26/01/2022.
//

import Foundation

struct UserNetwork {
    let listUser: [UserNode]
}

struct UserNode {
    let id: String
    let firstName: String
    let lastName: String
    let province: String
    let district: String
    let bio: String
    let email: String
    let dob: String
    let isMale: Bool
}
