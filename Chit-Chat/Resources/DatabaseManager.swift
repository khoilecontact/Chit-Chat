//
//  DatabaseManager.swift
//  Chit-Chat
//
//  Created by KhoiLe on 25/01/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation

/// Manager object to read and write to real time database in Firebase
final class DatabaseManager {
    ///Shared instance of class
    public static let shared = DatabaseManager()
    
    //force to use this init
    private init() {}
    
    private let database = Database.database(url: "https://chit-chat-fc877-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

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
    
    public enum DatabaseError: Error {
        case failedToFetch
        case failedToFind
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
                        "email": user.safeEmail,
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

extension DatabaseManager {
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("Users").child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
}

// MARK: -Sending messages / conversations

extension DatabaseManager {
    /*
     id {
        "messages": [
            {
                "id": String,
                "type": text, audio, photo,..
                "content": String
                "date": Date(),
                "sender_email": String
                "isRead": true/false
            }
        ]
     }
     
     conversation => [
        [
            "conversation_id": id
            "other_user_email":
            "latest_message": => {
                "date": Date()
                "latest_message": "message"
                "is_read": true/false
        ]
     ]
     */
    
    /// Create new conversation with other user email and first message sent to the User reference in the database
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email"),
              let currentName = UserDefaults.standard.value(forKey: "name") else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail as! String)
        
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            var message = ""
            
            switch firstMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = messageDate.toString(dateFormat: "dd/MM/YY")
            let conversationId =  firstMessage.messageId
            
            let newConversationData: [String: Any] = [
                "id": "conversation_\(conversationId)",
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": "conversation_\(conversationId)",
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            //update recipient entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([conversations])
                } else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
         
            // update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exist fir current user
                // we should append it
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            } else {
                // conversation array does not exist, create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    /// Add message to the conversationId array - hold all the message of the conversation
    private func finishCreatingConversation(name: String, conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id": String,
//            "type": text, audio, photo,..
//            "content": String
//            "date": Date(),
//            "sender_email": String
//            "isRead": true/false
//        }
        
        var message = ""
        
        switch firstMessage.kind {
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = messageDate.toString(dateFormat: "dd/MM/YY")
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") else {
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail as! String)
        
        let colletionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                colletionMessage
            ]
        ]
        
        database.child("conversation_\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Fetch and return all conversations for the user which has the email
    public func getAllConversations(for email: String, completion: @escaping (Result<[MessagesCollection], Error>) -> Void) {
        database.child("Users/\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [MessagesCollection] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let lastMessage = dictionary["latest_message"] as? [String: Any],
                      let date = lastMessage["date"] as? String,
                      let message = lastMessage["message"] as? String,
                      let isRead = lastMessage["is_read"] as? Bool else {
                          print("invalid type variable ...")
                          return nil
                      }
                
                let latestMessageObject = LatestMessage(
                    date: date,
                    text: message,
                    isRead: isRead)
                
                return MessagesCollection(id: conversationId,
                                          name: name,
                                          otherUserEmail: otherUserEmail,
                                          latestMessage: latestMessageObject)
                
            })
            
            completion(.success(conversations))
        })
    }
    
    /// Get all messages for a given conversations
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("Conversations/\(id)/messages").observe(.value, with: { snapshot in
            //print("getAllMessagesForConversation: \(id)")
            guard let value = snapshot.value as? [[String: Any]] else {
                print("invalid messages return values")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = dateFormatter.date(from: dateString)
                      else {
                    print("A value is wrong")
                    return nil
                }
                
                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string: content), let placeholder = UIImage(named: "ImagePlaceholder") else {
                        return nil
                    }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string: content), let placeholder = UIImage(named: "VideoPlaceholder") else {
                        return nil
                    }
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                } else if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponents[0]), let latitude = Double(locationComponents[1]) else {
                        print("Fail in convert location components")
                        return nil
                    }
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 300, height: 300))
                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else { return nil }
                
                let sender = Sender(photo: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            })
            
            completion(.success(messages))
        })
    }
    
    /// Send a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, otherUserEmail: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // Add new message to messages
        // update sender's latest message
        // upadte recipient latest message
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("Conversations/\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                print("Video recieve")
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let dateString = newMessage.sentDate
            //let conversationId =  newMessage.messageId
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") else {
                completion(false)
                return
            }
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail as! String)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            self?.database.child("Conversations/\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                self?.database.child("Users/\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updateValue: [String: Any] = [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0
                        
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        
                        //If we found the conversation
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updateValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        } else {
                            //We might delete it
                            let newConversationData: [String: Any] = [
                                "id": "\(conversation)",
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updateValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                        
                    } else {
                        let newConversationData: [String: Any] = [
                            "id": "\(conversation)",
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updateValue
                        ]
                        
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                                        
                    self?.database.child("Users/\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //Update latest message for recipient user
                        self?.database.child("Users/\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            var databaseEntryConversations = [[String: Any]]()
                            let updateValue: [String: Any] = [
                                "date": dateString,
                                "message": message,
                                "is_read": false
                            ]
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                print("No current user name found")
                                return
                            }
                            
                            if var otherUserConversation = snapshot.value as? [[String: Any]] {
                                
                                var targetConversation: [String: Any]?
                                var position = 0
                                
                                for conversationDictionary in otherUserConversation {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updateValue
                                    
                                    otherUserConversation[position] = targetConversation
                                    databaseEntryConversations = otherUserConversation
                                } else {
                                    //failed to find in current collection
                                    let newConversationData: [String: Any] = [
                                        "id": "\(conversation)",
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updateValue
                                    ]
                                    otherUserConversation.append(newConversationData)
                                    databaseEntryConversations = otherUserConversation
                                }
                                
                            } else {
                                //current collection doesnot exists
                                let newConversationData: [String: Any] = [
                                    "id": "\(conversation)",
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updateValue
                                ]
                                
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                           
                            
                            self?.database.child("Users/\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            })
        })
    }
    
    /// Delete a conversation in the conversation in Firebase
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        //Get all conversations for current user
        //Delete the conversation in collection with target id
        //Reset those conversaitons
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String, id == conversationId {
                        break
                    }
                    positionToRemove += 1
                }
                
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    print("Delete conversation success")
                    completion(true)
                })
            }
        })
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: {
            snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFind))
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFind))
                    return
                }
                
                completion(.success(id))
                return
            }
            
            completion(.failure(DatabaseError.failedToFind))
            return
        })
    }
}

//struct ChatAppUser {
//    let firstName: String
//    let lastName: String
//    let emailAddress: String
//    
//    var safeEmail: String {
//        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
//        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
//    
//    var profilePictureFileName: String {
//        return "\(safeEmail)_profile_picture.png"
//    }
//}
//

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
