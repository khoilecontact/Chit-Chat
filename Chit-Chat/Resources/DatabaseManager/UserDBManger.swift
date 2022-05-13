//
//  UserDatabaseManger.swift
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
    ///Check if user exists for given email
    ///- email: Target email to be checked
    ///- completion: Async closure to return with result
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("Users").child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })

    }
    
    // MARK: - Get all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        database.child("Users_list").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    /*
     users: [
        [
            "name":
            "safeEmail":
        ],
         [
             "name":
             "safeEmail":
         ]
     ]
     */
    
    ///insert new user to database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        let UsersListRef = database.child("Users")
        
        UsersListRef.child(user.safeEmail).setValue([
            "id" : user.id,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "bio" : user.bio,
            "email" : user.email,
            "dob" : user.dob,
            "is_male" : user.isMale,
            "province" : user.province,
            "district" : user.district,
            "friend_request_list": [],
            "sent_friend_request": [],
            "friend_list": [],
            "black_list": [],
            "conversations": [],
        ], withCompletionBlock: { [weak self] error, datareference in
            guard error ==  nil else {
                print("Failed to write to database")
                print(error ?? "")
                completion(false)
                return
            }

            
            self?.database.child("Users_list").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: Any]] {
                    //append to user dictionary
                    let newElement: [String: Any] = [
                        "id" : user.id,
                        "first_name": user.firstName,
                        "last_name" : user.lastName,
                        "email": user.email,
                        "bio" : user.bio,
                        "dob" : user.dob,
                        "is_male" : user.isMale,
                        "province" : user.province,
                        "district" : user.district,
                        "friend_request_list": [],
                        "sent_friend_request": [],
                        "friend_list": [],
                        "black_list": [],
                        "conversations": [],
                    ]
                    
                    usersCollection.append(newElement)
                    
                    self?.database.child("Users_list").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                } else {
                    //create an array
                    let newCollection: [[String: Any]] = [
                        [
                            "id" : user.id,
                            "first_name": user.firstName,
                            "last_name" : user.lastName,
                            "email": user.email,
                            "bio" : user.bio,
                            "dob" : user.dob,
                            "is_male" : user.isMale,
                            "province" : user.province,
                            "district" : user.district,
                            "friend_request_list": [],
                            "sent_friend_request": [],
                            "friend_list": [],
                            "black_list": [],
                            "conversations": [],
                        ]
                    ]
                    self?.database.child("Users_list").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            completion(true)
        })
    }
    
    /// Insert unverified user
    public func insertUnverifiedUser(with user: User, completion: @escaping (Bool) -> Void) {
        let UsersListRef = database.child("Unverified_users")
        
        UsersListRef.child(user.safeEmail).setValue([
            "id" : user.id,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "bio" : user.bio,
            "email" : user.email,
            "dob" : user.dob,
            "is_male" : user.isMale,
            "province" : user.province,
            "district" : user.district,
            "friend_request_list": [],
            "sent_friend_request": [],
            "friend_list": [],
            "black_list": [],
            "conversations": [],
        ], withCompletionBlock: { error, datareference in
            guard error ==  nil else {
                print("Failed to write to database")
                print(error ?? "")
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    func updateVerifiedUser(with email: String, completion: @escaping (Bool) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("Unverified_users").child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            guard let id = data["id"] as? String,
                  let firstName = data["first_name"] as? String,
                  let lastName = data["last_name"] as? String,
                  let dob = data["dob"] as? String,
                  let isMale = data["is_male"] as? Bool,
                  let province = data["province"] as? String,
                  let district = data["district"] as? String
            else {
                      completion(false)
                      return
                  }
            
            let UsersListRef = self.database.child("Users")
            
            UsersListRef.child(safeEmail).setValue([
                "id" : id,
                "first_name": firstName,
                "last_name": lastName,
                "bio" : "",
                "email" : email,
                "dob" : dob,
                "is_male" : isMale,
                "province" : province,
                "district" : district,
                "friend_request_list": [],
                "sent_friend_request": [],
                "friend_list": [],
                "black_list": [],
                "conversations": [],
            ], withCompletionBlock: { [weak self] error, datareference in
                guard error ==  nil else {
                    print("Failed to write to database")
                    print(error ?? "")
                    completion(false)
                    return
                }

                self?.database.child("Users_list").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    if var usersCollection = snapshot.value as? [[String: Any]] {
                        //append to user dictionary
                        let newElement: [String: Any] = [
                            "id" : id,
                            "first_name": firstName,
                            "last_name" : lastName,
                            "email": email,
                            "bio" : "",
                            "dob" : dob,
                            "is_male" : isMale,
                            "province" : province,
                            "district" : district,
                            "friend_request_list": [],
                            "sent_friend_request": [],
                            "friend_list": [],
                            "black_list": [],
                            "conversations": [],
                        ]
                        
                        usersCollection.append(newElement)
                        
                        self?.database.child("Users_list").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            // Verified, delete from unverified users
                            self?.database.child("Unverified_users").child(safeEmail).removeValue()
                            
                            completion(true)
                        })
                        
                    } else {
                        //create an array
                        let newCollection: [[String: Any]] = [
                            [
                                "id" : id,
                                "first_name": firstName,
                                "last_name" : lastName,
                                "email": email,
                                "bio" : "",
                                "dob" : dob,
                                "is_male" : isMale,
                                "province" : province,
                                "district" : district,
                                "friend_request_list": [],
                                "sent_friend_request": [],
                                "friend_list": [],
                                "black_list": [],
                                "conversations": [],
                            ]
                        ]
                        self?.database.child("Users_list").setValue(newCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            // Verified, delete from unverified users
                            self?.database.child("Unverified_users").child(safeEmail).removeValue()
                            
                            completion(true)
                        })
                    }
                })
            })
        })
    }
    
    public func updateUserInfo(with email: String, changesArray: [String: Any], completion: @escaping (Bool) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        // Update in Users
        let UsersListRef = database.child("Users")

        UsersListRef.child(safeEmail).updateChildValues(changesArray, withCompletionBlock: { error, _ in
            guard let _ = error else {
                completion(false)
                return
            }
        })
        
        // Update in Users_list
        self.database.child("Users_list").observeSingleEvent(of: .value, with: { snapshot in
            var userIndex = 0
            
            if var usersCollection = snapshot.value as? [[String: Any]] {
                for index in 0 ..< usersCollection.count {
                    if usersCollection[index]["email"] as! String == email {
                        userIndex = index
                        break
                    }
                }
                
                // Apply the changes
                usersCollection[userIndex]["first_name"] = changesArray["first_name"]
                usersCollection[userIndex]["last_name"] = changesArray["last_name"]
                usersCollection[userIndex]["bio"] = changesArray["bio"]
                usersCollection[userIndex]["dob"] = changesArray["dob"]
                usersCollection[userIndex]["is_male"] = changesArray["is_male"]
                usersCollection[userIndex]["province"] = changesArray["province"]
                usersCollection[userIndex]["district"] = changesArray["district"]
                
                self.database.child("Users_list").setValue(usersCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                })
                
                completion(true)
            }
        })
    }
    
    public func resetPassword(with email: String, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.userExists(with: email, completion: { exist in
            if !exist {
                completion(false)
            } else {
                Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
                    guard error != nil else {
                        completion(false)
                        return
                    }
                })
                
                completion(true)
            }
        })
    }
    
}
