//
//  UserManager.swift
//  Chit-Chat
//
//  Created by KhoiLe on 24/03/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation

final class UserManger {
    public static let shared = UserManger()
    
    //force to use this init
    private init() {}
    
    private let database = Database.database(url: "https://chit-chat-fc877-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension UserManger {
    
    public func getAllFriendOfUser(with unSafeEmail: String, completion: @escaping ([UserNode]) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/friend_list").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion([])
                return
            }
            
            var result: [UserNode] = []
            
            for rawUser in value {
                guard let id = rawUser["id"] as? String,
                      let email = rawUser["email"] as? String,
                      let lastName = rawUser["last_name"] as? String,
                      let firstName = rawUser["first_name"] as? String,
                      let bio = rawUser["bio"] as? String?,
                      let dob = rawUser["dob"] as? String?,
                      let isMale = rawUser["is_male"] as? Bool,
                      let province = rawUser["province"] as? String,
                      let district = rawUser["district"] as? String
                else {
                    print("excepted type")
                    return
                }
                
                let userNode = UserNode(id: id,
                                        firstName: firstName,
                                        lastName: lastName,
                                        province: province,
                                        district: district,
                                        bio: bio ?? "",
                                        email: email,
                                        dob: dob ?? "",
                                        isMale: isMale)
                
                result.append(userNode)
            }
            
            completion(result)
        })
    }
    
    public func getAllFriendRequestOfUser(with unSafeEmail: String, completion: @escaping ([UserNode]) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/friend_request_list").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion([])
                return
            }
            
            var result: [UserNode] = []
            
            for rawUser in value {
                guard let id = rawUser["id"] as? String,
                      let email = rawUser["email"] as? String,
                      let lastName = rawUser["last_name"] as? String,
                      let firstName = rawUser["first_name"] as? String,
                      let bio = rawUser["bio"] as? String?,
                      let dob = rawUser["dob"] as? String?,
                      let isMale = rawUser["is_male"] as? Bool,
                      let province = rawUser["province"] as? String,
                      let district = rawUser["district"] as? String
                else {
                    print("excepted type")
                    return
                }
                
                let userNode = UserNode(id: id,
                                        firstName: firstName,
                                        lastName: lastName,
                                        province: province,
                                        district: district,
                                        bio: bio ?? "",
                                        email: email,
                                        dob: dob ?? "",
                                        isMale: isMale)
                
                result.append(userNode)
            }
            
            completion(result)
        })
    }
    
    public func getAllSentFriendRequestOfUser(with unSafeEmail: String, completion: @escaping ([UserNode]) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/sent_friend_request").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion([])
                return
            }
            
            var result: [UserNode] = []
            
            for rawUser in value {
                guard let id = rawUser["id"] as? String,
                      let email = rawUser["email"] as? String,
                      let lastName = rawUser["last_name"] as? String,
                      let firstName = rawUser["first_name"] as? String,
                      let bio = rawUser["bio"] as? String?,
                      let dob = rawUser["dob"] as? String?,
                      let isMale = rawUser["is_male"] as? Bool,
                      let province = rawUser["province"] as? String,
                      let district = rawUser["district"] as? String
                else {
                    print("excepted type")
                    return
                }
                
                let userNode = UserNode(id: id,
                                        firstName: firstName,
                                        lastName: lastName,
                                        province: province,
                                        district: district,
                                        bio: bio ?? "",
                                        email: email,
                                        dob: dob ?? "",
                                        isMale: isMale)
                
                result.append(userNode)
            }
            
            completion(result)
        })
    }
    
    public func getAllBlacklistOfUser(with unSafeEmail: String, completion: @escaping ([UserNode]) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
        
        database.child("Users/\(safeEmail)/black_list").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion([])
                return
            }
            
            var result: [UserNode] = []
            
            for rawUser in value {
                guard let id = rawUser["id"] as? String,
                      let email = rawUser["email"] as? String,
                      let lastName = rawUser["last_name"] as? String,
                      let firstName = rawUser["first_name"] as? String,
                      let bio = rawUser["bio"] as? String?,
                      let dob = rawUser["dob"] as? String?,
                      let isMale = rawUser["is_male"] as? Bool,
                      let province = rawUser["province"] as? String,
                      let district = rawUser["district"] as? String
                else {
                    print("excepted type")
                    return
                }
                
                let userNode = UserNode(id: id,
                                        firstName: firstName,
                                        lastName: lastName,
                                        province: province,
                                        district: district,
                                        bio: bio ?? "",
                                        email: email,
                                        dob: dob ?? "",
                                        isMale: isMale)
                
                result.append(userNode)
            }
            
            completion(result)
        })
    }
}
