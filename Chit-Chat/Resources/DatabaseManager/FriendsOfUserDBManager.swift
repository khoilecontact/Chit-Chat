//
//  FriendsOfUserDatabaseManager.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 22/03/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation


extension DatabaseManager {
    // MARK: - Friend Handle
    // MARK: - Get all user's friend
    public func getAllFriendsOfUser(with unSafeEmail: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/friend_list").observe( .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public func getAllFriendRequestOfUser(with unSafeEmail: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/friend_request_list").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public func getAllSentFriendRequestOfUser(with unSafeEmail: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/sent_friend_request").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public func getBlackListOfUser(with unSafeEmail: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/black_list").observeSingleEvent(of: .value, with: { snapshot in
//            print(snapshot.val())
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public func sendFriendRequest(with otherUser: UserNode, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.failure(DatabaseError.failedToFind))
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        database.child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let email = value["email"] as? String,
               let firstName = value["first_name"] as? String,
               let lastName = value["last_name"] as? String,
               let dob = value["dob"] as? String?,
               let province = value["province"] as? String?,
               let district = value["district"] as? String?,
               let bio = value["bio"] as? String?,
               let id = value["id"] as? String,
               let isMale = value["is_male"] as? Bool,
               var sentFriendRequest = value["sent_friend_request"] as? [[String: Any]]?
            {
                let myInfo: [String: Any] = [
                    "email": email,
                    "first_name": firstName,
                    "province": province ?? "",
                    "district": district ?? "",
                    "last_name": lastName,
                    "dob": dob ?? "",
                    "bio": bio ?? "",
                    "id": id,
                    "is_male": isMale
                ]
                
                let myFriendRequest: [String: Any] = [
                    "email": otherUser.email,
                    "first_name": otherUser.firstName,
                    "last_name": otherUser.lastName,
                    "province": otherUser.province,
                    "district": otherUser.district,
                    "dob": otherUser.dob,
                    "bio": otherUser.bio,
                    "id": otherUser.id,
                    "is_male": otherUser.isMale
                ]
                
                sentFriendRequest?.append(myFriendRequest)
                
                strongSelf.database.child("Users/\(safeEmail)/sent_friend_request").setValue(sentFriendRequest ?? [myFriendRequest]) { error, _ in
                    guard error == nil else {
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                }
                
                // other
                strongSelf.database.child("Users/\(otherSafeEmail)").observeSingleEvent(of: .value) { otherSnapshot in
                    
                    guard let otherValue = otherSnapshot.value as? [String: Any] else {
                        print("Failed to fetch other profile")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    
                    if var currentRequestList = otherValue["friend_request_list"] as? [[String: Any]]? {
                        
                        currentRequestList?.append(myInfo)
                        
                        strongSelf.database.child("Users/\(otherSafeEmail)/friend_request_list").setValue(currentRequestList ?? [myInfo]) { error, _ in
                            guard error == nil else {
                                completion(.failure(DatabaseError.failedToFetch))
                                return
                            }
                            
                            completion(.success(true))
                            return
                        }
                    }
                }
                
            }
            
        })
    }
    
    func acceptFriendRequest(with otherUser: UserNode, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.failure(DatabaseError.failedToFind))
            return
        }
        
        /// move from my frequest_list -> my friend_list && move from other's sentRequest_list -> other's friend_list
        
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        database.child("Users/\(mySafeEmail)").observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if var friendList = value["friend_list"] as? [[String: Any]]?,
               var friendRequestList = value["friend_request_list"] as? [[String: Any]]
            {
                // find and move rhe user handling to friend table
                let request: [[String: Any]] = friendRequestList.filter({
                    guard let email = $0["email"] as? String else { return false }
                    
                    return email.hasPrefix(otherUser.email)
                })
                
                if !request.isEmpty {
                    friendRequestList.removeAll(where: { request[0] as NSDictionary == $0 as NSDictionary })
                    friendList?.append(request[0])
                }
                
                let updateChild = [
                    "friend_request_list": friendRequestList,
                    "friend_list": friendList ?? [request[0]]
                ]
                
                strongSelf.database.child("Users/\(mySafeEmail)").updateChildValues(updateChild) { error, _ in
                    guard error == nil else {
                        print("Failed to save")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                }
                
                // request sender
                strongSelf.database.child("Users/\(otherSafeEmail)").observe(.value) { otherSnapshot in
                    // request sender
                    guard let otherValue = otherSnapshot.value as? [String: Any] else {
                        print("Failed to fetch sender profile")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    
                    if var otherfriendList = otherValue["friend_list"] as? [[String: Any]]?,
                       var otherSentFriendRequestList = otherValue["sent_friend_request"] as? [[String: Any]]
                    {
                        // find and move the user handling from sentRequest to friend table
                        let otherRequest: [[String: Any]] = otherSentFriendRequestList.filter({
                            guard let email = $0["email"] as? String else { return false }
                            
                            return email.hasPrefix(myEmail)
                        })
                        
                        if !otherRequest.isEmpty {
                            otherSentFriendRequestList.removeAll(where: { otherRequest[0] as NSDictionary == $0 as NSDictionary })
                            otherfriendList?.append(otherRequest[0])
                        }
                            
                        let otherUpdateChild = [
                            "sent_friend_request": otherSentFriendRequestList,
                            "friend_list": otherfriendList ?? [otherRequest[0]]
                        ]
                        
                        strongSelf.database.child("Users/\(otherSafeEmail)").updateChildValues(otherUpdateChild) { error, _ in
                            guard error == nil else {
                                print("Failed to save at other user")
                                completion(.failure(DatabaseError.failedToFetch))
                                return
                            }
                            
                            completion(.success(true))
                        }
                    }
                    
                }
            }
            
            
        }
    }
    
    func deniesFriendRequest(with otherUser: UserNode, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.failure(DatabaseError.failedToFind))
            return
        }
        
        /// move from my frequest_list -> my friend_list && move from other's sentRequest_list -> other's friend_list
        
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        database.child("Users/\(mySafeEmail)").observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if var friendRequestList = value["friend_request_list"] as? [[String: Any]]
            {
                // find and move rhe user handling to friend table
                let request: [[String: Any]] = friendRequestList.filter({
                    guard let email = $0["email"] as? String else { return false }
                    
                    return email.hasPrefix(otherUser.email)
                })
                
                friendRequestList.removeAll(where: { request[0] as NSDictionary == $0 as NSDictionary })
                
                strongSelf.database.child("Users/\(mySafeEmail)/friend_request_list").setValue(friendRequestList, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                })
                
                // request sender
                strongSelf.database.child("Users/\(otherSafeEmail)").observe(.value) { snapshot in
                    // request sender
                    guard let otherValue = snapshot.value as? [String: Any] else {
                        print("Failed to fetch sender profile")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    
                    if var otherSentFriendRequestList = otherValue["sent_friend_request"] as? [[String: Any]]
                    {
                        // find and move the user handling from sentRequest to friend table
                        let otherRequest: [[String: Any]] = otherSentFriendRequestList.filter({
                            guard let email = $0["email"] as? String else { return false }
                            
                            return email.hasPrefix(myEmail)
                        })
                        
                        if !otherRequest.isEmpty {
                            otherSentFriendRequestList.removeAll(where: { otherRequest[0] as NSDictionary == $0 as NSDictionary })
                        }
                            
                        strongSelf.database.child("Users/\(otherSafeEmail)/sent_friend_request").setValue(otherSentFriendRequestList, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(.failure(DatabaseError.failedToFetch))
                                return
                            }
                            
                            completion(.success(true))
                        })
                    }
                }
            }
        }
    }
    
    func revokeFriendRequest(with otherUser: UserNode, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.failure(DatabaseError.failedToFind))
            return
        }
        
        /// move from my frequest_list -> my friend_list && move from other's sentRequest_list -> other's friend_list
        
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        database.child("Users/\(mySafeEmail)").observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if var sentFriendRequestList = value["sent_friend_request"] as? [[String: Any]]
            {
                // find and move rhe user handling to friend table
                let request: [[String: Any]] = sentFriendRequestList.filter({
                    guard let email = $0["email"] as? String else { return false }
                    
                    return email.hasPrefix(otherUser.email)
                })
                
                sentFriendRequestList.removeAll(where: { request[0] as NSDictionary == $0 as NSDictionary })
                
                strongSelf.database.child("Users/\(mySafeEmail)/sent_friend_request").setValue(sentFriendRequestList, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                })
                
                // request sender
                strongSelf.database.child("Users/\(otherSafeEmail)").observe(.value) { snapshot in
                    // request sender
                    guard let otherValue = snapshot.value as? [String: Any] else {
                        print("Failed to fetch sender profile")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    
                    if var otherFriendRequestList = otherValue["friend_request_list"] as? [[String: Any]]
                    {
                        // find and move the user handling from sentRequest to friend table
                        let otherRequest: [[String: Any]] = otherFriendRequestList.filter({
                            guard let email = $0["email"] as? String else { return false }
                            
                            return email.hasPrefix(myEmail)
                        })
                        
                        if !otherRequest.isEmpty {
                            otherFriendRequestList.removeAll(where: { otherRequest[0] as NSDictionary == $0 as NSDictionary })
                        }
                            
                        strongSelf.database.child("Users/\(otherSafeEmail)/friend_request_list").setValue(otherFriendRequestList, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(.failure(DatabaseError.failedToFetch))
                                return
                            }
                            
                            completion(.success(true))
                        })
                    }
                }
            }
        }
    }
    
    func unfriend(with otherUser: UserNode, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.failure(DatabaseError.failedToFind))
            return
        }
                
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        database.child("Users/\(mySafeEmail)").observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if var sentFriendRequestList = value["friend_list"] as? [[String: Any]]
            {
                // find and move rhe user handling to friend table
                let request: [[String: Any]] = sentFriendRequestList.filter({
                    guard let email = $0["email"] as? String else { return false }
                    
                    return email.hasPrefix(otherUser.email)
                })
                
                if !request.isEmpty {
                    sentFriendRequestList.removeAll(where: { request[0] as NSDictionary == $0 as NSDictionary })
                }
                
                strongSelf.database.child("Users/\(mySafeEmail)/friend_list").setValue(sentFriendRequestList, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                })
                
                // other person
                strongSelf.database.child("Users/\(otherSafeEmail)").observe(.value) { snapshot in
                    // request sender
                    guard let otherValue = snapshot.value as? [String: Any] else {
                        print("Failed to fetch sender profile")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    
                    if var otherFriendRequestList = otherValue["friend_list"] as? [[String: Any]]
                    {
                        // find and move the user handling from sentRequest to friend table
                        let otherRequest: [[String: Any]] = otherFriendRequestList.filter({
                            guard let email = $0["email"] as? String else { return false }
                            
                            return email.hasPrefix(myEmail)
                        })
                        
                        for index in 0 ..< otherFriendRequestList.count {
                            if otherFriendRequestList.count > 0 && index <= otherFriendRequestList.count && otherRequest.count > 0 {
                                if otherRequest[0] as NSDictionary == otherFriendRequestList[index] as NSDictionary {
                                    otherFriendRequestList.remove(at: index)
                                }
                            }
                        }
                        //otherFriendRequestList.removeAll(where: { otherRequest[0] as NSDictionary == $0 as NSDictionary })
                        
                        strongSelf.database.child("Users/\(otherSafeEmail)/friend_list").setValue(otherFriendRequestList, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(.failure(DatabaseError.failedToFetch))
                                return
                            }
                            
                            completion(.success(true))
                        })
                    }
                }
            }
        }
    }
    
    /// Unfriend, deny, revoke friend status of two users and delete conversation on current user
    func addToBlackList(with otherUser: UserNode, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.failure(DatabaseError.failedToFind))
            return
        }
        
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let otherSafeEmail = DatabaseManager.safeEmail(emailAddress: otherUser.email)
        
        database.child("Users/\(mySafeEmail)").observe(.value) { [weak self] snapshot in
            
            if let value = snapshot.value as? [String: Any] {
                var conversations: [[String: Any]] = value["conversations"] as? [[String: Any]] ?? []
                
                // Delete conversation of current user
                for conversationIndex in 0 ..< conversations.count {
                    if conversations[conversationIndex]["other_user_email"] as? String == otherSafeEmail {
                        conversations.remove(at: conversationIndex)
                        break
                    }
                }
                
                // Add other user to black list
                if var blackList: [[String: Any]] = value["black_list"] as? [[String: Any]] {
                    let newBlackListElement: [String: Any] = [
                        "id": otherUser.id,
                        "first_name": otherUser.firstName,
                        "last_name": otherUser.lastName,
                        "province": otherUser.province,
                        "district": otherUser.district,
                        "bio": otherUser.bio,
                        "email": otherUser.email,
                        "dob": otherUser.dob,
                        "is_male": otherUser.isMale
                    ]
                    
                    blackList.append(newBlackListElement)
                    
                    self?.database.child("Users/\(mySafeEmail)/black_list").setValue(blackList, withCompletionBlock: { error, _ in
                        if error == nil {
                            print("Error in adding in existing black list of current user")
                        }
                    })
                } else {
                    let newBlackListElement: [String: Any] = [
                        "id": otherUser.id,
                        "first_name": otherUser.firstName,
                        "last_name": otherUser.lastName,
                        "province": otherUser.province,
                        "district": otherUser.district,
                        "bio": otherUser.bio,
                        "email": otherUser.email,
                        "dob": otherUser.dob,
                        "is_male": otherUser.isMale
                    ]
                    
                    let newBlackList: [[String: Any]] = [
                        newBlackListElement
                    ]
                    
                    self?.database.child("Users/\(mySafeEmail)/black_list").setValue(newBlackList, withCompletionBlock: { error, _ in
                        if error != nil {
                            print("Error in adding in existing black list of new black list of user")
                        }
                    })
                }
                
                
                
                self?.database.child("Users/\(mySafeEmail)/conversations").setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(.failure(DatabaseError.failedToSave))
                        return
                    }
                })
            } else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            // Unfriend user
            DatabaseManager.shared.unfriend(with: otherUser, completion: { [weak self] unfriendResult in
                DatabaseManager.shared.revokeFriendRequest(with: otherUser, completion: { revokeRequestResult in
                    DatabaseManager.shared.deniesFriendRequest(with: otherUser, completion: { denyRequestResult in
                        switch unfriendResult {
                        case .success(_):
                            switch revokeRequestResult {
                            case .success(_):
                                switch denyRequestResult {
                                case .success(_):
                                    // Get current user's data
                                    self?.database.child("Users/\(mySafeEmail)").observe(.value) { snapshot in
                                        guard let value = snapshot.value as? [String: Any] else {
                                            completion(.failure(DatabaseError.failedToFetch))
                                            return
                                        }
                                        
                                        // Delete conversation of current user
                                        if var conversations = value["conversations"] as? [[String: Any]] {
                                            for conversationIndex in 0 ..< conversations.count {
                                                if conversations[conversationIndex]["other_user_email"] as? String == otherSafeEmail {
                                                    conversations.remove(at: conversationIndex)
                                                    break
                                                }
                                            }
                                            
                                            self?.database.child("Users/\(mySafeEmail)/conversations").setValue(conversations, withCompletionBlock: { error, _ in
                                                guard error == nil else {
                                                    completion(.failure(DatabaseError.failedToSave))
                                                    return
                                                }
                                            })
                                        }
                                        
                                        // Add other user to blacklist
                                        if var blackList = value["black_list"] as? [[String: Any]] {
                                            
                                            let newBlackListItem: [String: Any] = [
                                                "email": otherUser.email,
                                                "first_name": otherUser.firstName,
                                                "last_name": otherUser.lastName,
                                                "province": otherUser.province,
                                                "district": otherUser.district,
                                                "dob": otherUser.dob,
                                                "bio": otherUser.bio,
                                                "id": otherUser.id,
                                                "is_male": otherUser.isMale
                                            ]
                                            
                                            blackList.append(newBlackListItem)
                                            
                                            self?.database.child("Users/\(mySafeEmail)/black_list").setValue(blackList) { error, _ in
                                                guard error == nil else {
                                                    completion(.failure(DatabaseError.failedToFetch))
                                                    return
                                                }
                                            }
                                            
                                            completion(.success(true))
                                        }
                                    }
                                    break
                                case .failure(_):
                                    print("Failed to deny user")
                                    break
                                }
                                break
                            case .failure(_):
                                print("Failed to revoke friend request of user")
                                break
                            }
                            break
                        case .failure(_):
                            print("Failed to unfriend user")
                            break
                        }
                    })
                })
            })
        }
        
        
       
    }
    
    func unseggest(with otherUser: UserNode, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
}
