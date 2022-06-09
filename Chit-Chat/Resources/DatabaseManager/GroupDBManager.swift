//
//  GroupDBManager.swift
//  Chit-Chat
//
//  Created by KhoiLe on 21/04/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import ChatMessageKit
import CoreLocation

// MARK: Grouping and group

extension DatabaseManager {
    public func groupExists(with groupID: String, completion: @escaping ((Bool) -> Void)) {
        
        database.child("Groups").child(groupID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func insertGroup(with group: Group, users: [UserNode], completion: @escaping (Bool) -> Void) {
        
        let groupRef = database.child("Groups")
        
        var convertedMembers: [[String: Any]] = []
        
        for person in users {
            convertedMembers.append([
                "id": person.id,
                "email": person.email,
                "dob": person.dob,
                "last_name": person.lastName,
                "first_name": person.firstName,
                "bio": person.bio,
                "district": person.district,
                "province": person.province,
                "is_male": person.isMale,
            ])
        }
        
        // get my info and append to group
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let mySafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("Users/\(mySafeEmail)").observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            guard let id = value["id"] as? String,
                  let email = value["email"] as? String,
                  let dob = value["dob"] as? String,
                  let lastName = value["last_name"] as? String,
                  let firstName = value["first_name"] as? String,
                  let bio = value["bio"] as? String,
                  let district = value["district"] as? String,
                  let province = value["province"] as? String,
                  let isMale = value["is_male"] as? Bool else {
                print("Invalid value")
                completion(false)
                return
            }
            
            //                convertedMembers.append([
            //                    "id": person.id,
            //                    "email": person.email,
            //                    "dob": person.dob,
            //                    "last_name": person.lastName,
            //                    "first_name": person.firstName,
            //                    "bio": person.bio,
            //                    "district": person.district,
            //                    "province": person.province,
            //                    "is_male": person.isMale
            //                ])
            
            let myInfo: [String : Any] = [
                "id": id,
                "email": email,
                "dob": dob,
                "last_name": lastName,
                "first_name": firstName,
                "bio": bio,
                "district": district,
                "province": province,
                "is_male": isMale
            ]
            
            convertedMembers.append(myInfo)
            
            groupRef.child(group.id).setValue([
                "id": group.id,
                "name": group.name,
                "members": convertedMembers
            ], withCompletionBlock: { error, databaseReference in
                guard error == nil else {
                    print("Failed to write to database: \(error)")
                    completion(false)
                    return
                }
                
                completion(true)
            })
        }

    }
    
    public func updateGroupInfo(with email: String, changesArray: [String: Any], completion: @escaping (Bool) -> Void) {
        
    }
    
    public func getAllGroupMembers(with id: String, completion: @escaping ((Bool) -> Void)) {
        
    }
    
}
