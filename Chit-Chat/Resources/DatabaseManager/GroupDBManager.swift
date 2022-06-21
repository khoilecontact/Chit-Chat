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
                "members": convertedMembers,
                "admin": group.admin
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
    
    public func getAllGroupMembers(with id: String, completion: @escaping ((Result<[UserNode],Error>)) -> Void) {
        
        database.child("Groups/\(id)/members").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let member: [UserNode] = value.compactMap({ dictionary in
                guard let id = dictionary["id"] as? String,
                        let firstName = dictionary["first_name"] as? String,
                        let lastName = dictionary["last_name"] as? String,
                        let province = dictionary["province"] as? String,
                        let district = dictionary["district"] as? String,
                        let bio = dictionary["bio"] as? String,
                        let email = dictionary["email"] as? String,
                        let dob = dictionary["dob"] as? String,
                      let isMale = dictionary["is_male"] as? Bool else {
                    print("Invalid value")
                    return nil
                }
            
                return UserNode(id: id, firstName: firstName, lastName: lastName, province: province, district: district, bio: bio, email: email, dob: dob, isMale: isMale)
            })
            
            completion(.success(member))
        })
        
    }
    
    public func checkIsAdminOfGroup(with groupId: String, unsafeEmail: String, completion: @escaping (Bool) -> Void) {
        
        database.child("Groups/\(groupId)/admin").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String] else {
                print("Failed to fetch admin of group")
                completion(false)
                return
            }
            
            if value.contains(unsafeEmail) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func fetchAdminOfGroup(with groupId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        
        database.child("Groups/\(groupId)/admin").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String] else {
                print("Failed to fetch admin of group")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public func deleteMemberFromGroup(with unSafeEmail: String, groupId: String, isAdmin: Bool, completion: @escaping (Bool) -> Void) {
        guard isAdmin == true else {
            print("Unauthorized")
            completion(false)
            return
        }
        
        // remove user from Group
        database.child("Groups/\(groupId)/members").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            guard var memberList = snapshot.value as? [[String: Any]], memberList.count >= 1 else {
                completion(false)
                return
            }
            
            memberList.removeAll(where: { $0["email"] as! String == unSafeEmail })
            
            strongSelf.database.child("Groups/\(groupId)/members").setValue(memberList, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: unSafeEmail)
                // remove group_conversation from user
                strongSelf.database.child("Users/\(safeEmail)/group_conversations").observeSingleEvent(of: .value) { usersnapshot in
                    guard var userGroupConversation = usersnapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    userGroupConversation.removeAll(where: { $0["groupId"] as! String == groupId })
                    
                    strongSelf.database.child("Users/\(safeEmail)/group_conversations").setValue(userGroupConversation) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            })
        }
    }
    
    public func addMemberToGroup(with newMembers: [UserNode], groupId: String, completion: @escaping (Bool) -> Void ) {
        guard !newMembers.isEmpty else {
            completion(false)
            print("The members of group must not be empty")
            return
        }
        
        var convertedMembers: [[String: Any]] = []
        
        for person in newMembers {
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
        
        database.child("Groups/\(groupId)/members").setValue(convertedMembers, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                print("Failed to write new members to database")
                return
            }
            
            completion(true)
        })
    }
    
    public func deleteGroup(with groupId: String, conversationId: String, isAdmin: Bool, completion: @escaping (Result<Bool, DatabaseError>) -> Void ) {
        guard isAdmin == true else {
            print("Unauthorized")
            completion(.failure(DatabaseError.unauthorized))
            return
        }
        
        database.child("Groups/\(groupId)/members").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let memberValues = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                print("Failed to fetch members list")
                return
            }
            
            for memberValue in memberValues {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: memberValue["email"] as! String)
                
                self?.database.child("Users/\(safeEmail)/group_conversations").observeSingleEvent(of: .value, with: { groupConversationSnapshot in
                    guard var conversationValue = groupConversationSnapshot.value as? [[String: Any]] else {
                        print("Failed to fetch group conversations of user")
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    
                    conversationValue.removeAll(where: { $0["groupId"] as! String == groupId })
                    
                    self?.database.child("Users/\(safeEmail)/group_conversations").setValue(conversationValue, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Failed to write group conversations of user")
                            completion(.failure(DatabaseError.failedToSave))
                            return
                        }
                    })
                })
            }
            
            self?.database.child("Groups").observeSingleEvent(of: .value, with: { groupSnapshot in
                guard var groupValue = groupSnapshot.value as? [String: Any] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    print("Failed to fetch groups")
                    return
                }
                
                // groupValue.removeAll(where: { $0["id"] as! String == groupId })
                groupValue.removeValue(forKey: groupId as! String)
                
                self?.database.child("Groups").setValue(groupValue, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(.failure(DatabaseError.failedToSave))
                        print("Failed to write to database")
                        return
                    }
                    
                    self?.database.child("Group_Conversations").observeSingleEvent(of: .value, with: { groupConversationTableSnapshot in
                        guard var groupConversationTableValue = groupConversationTableSnapshot.value as? [String: Any] else {
                            completion(.failure(DatabaseError.failedToFetch))
                            print("Failed to fetch group conversations table")
                            return
                        }
                        
                        groupConversationTableValue.removeValue(forKey: conversationId)
                        
                        self?.database.child("Group_Conversations").setValue(groupConversationTableValue, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(.failure(DatabaseError.failedToSave))
                                print("Failed to write to database")
                                return
                            }
                            
                            completion(.success(true))
                        })
                    })
                })
            })
        }
    }
}
