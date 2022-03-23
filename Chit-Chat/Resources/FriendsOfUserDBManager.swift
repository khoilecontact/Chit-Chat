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
                
                friendRequestList.removeAll(where: { request[0] as NSDictionary == $0 as NSDictionary })
                friendList?.append(request[0])
                
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
                        
                        otherSentFriendRequestList.removeAll(where: { otherRequest[0] as NSDictionary == $0 as NSDictionary })
                        otherfriendList?.append(otherRequest[0])
                        
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
                        
                        otherSentFriendRequestList.removeAll(where: { otherRequest[0] as NSDictionary == $0 as NSDictionary })
                        
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
    
    func unseggest(with otherUser: UserNode, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
}
