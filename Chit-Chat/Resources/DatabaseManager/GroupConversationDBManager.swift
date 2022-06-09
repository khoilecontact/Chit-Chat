//
//  GroupConversationDBManager.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/05/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import ChatMessageKit
import CoreLocation

// MARK: Grouping and group

extension DatabaseManager {
    public func createNewGroupConversation(with id: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        // ---
        let ref = database.child("Users/\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
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
            case .audioCall(let callMessage):
                message = callMessage
            case .videoCall(let callMessage):
                message = callMessage
            case .custom(_):
                break
            }
            
            let conversationId = "group_conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "groupId": id,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // goto group record and send for all user
            self?.database.child("Groups/\(id)/members").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var members = snapshot.value as? [UserNode] {
                    
                    for member in members {
                        
                        if member.email == currentEmail { break }
                        
                        let safeOtherEmail = DatabaseManager.safeEmail(emailAddress: member.email)
                        
                        self?.database.child("Users/\(safeOtherEmail)/group_conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                            if var conversations = snapshot.value as? [[String: Any]] {
                                // append
                                conversations.insert(newConversationData, at: 0)
                                
                                self?.database.child("Users/\(safeOtherEmail)/group_conversations").setValue(conversations)
                            }
                            else {
                                // create new conversation
                                self?.database.child("Users/\(safeOtherEmail)/group_conversations").setValue([newConversationData])
                            }
                        })
                    }
                }
            })
            
            // update current user
            if var conversations = userNode["group_conversations"] as? [[String: Any]] {
                // append it
                
                conversations.insert(newConversationData, at: 0)
                userNode["group_conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingGroupConversation(name: name,
                                                          conversationID: conversationId,
                                                          firstMessage: firstMessage,
                                                          completion: completion)
                })
            }
            else {
                // create new
                userNode["group_conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingGroupConversation(name: name,
                                                          conversationID: conversationId,
                                                          firstMessage: firstMessage,
                                                          completion: completion)
                })
            }
        })
        
    }
    
    private func finishCreatingGroupConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
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
        case .audioCall(let callMessage):
            message = callMessage
            break
        case .videoCall(let callMessage):
            message = callMessage
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            // message
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "name": name,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("Group_Conversations/\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
            
        })
        
    }
    
    public func getAllGroupConversation(for safeEmail: String, completion: @escaping (Result<[GroupMessagesCollection],Error>) -> Void) {
        
        database.child("Users/\(safeEmail)/group_conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [GroupMessagesCollection] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let groupId = dictionary["groupId"] as? String,
                      let lastMessage = dictionary["latest_message"] as? [String: Any],
                      let date = lastMessage["date"] as? String,
                      let message = lastMessage["message"] as? String,
                      let isRead = lastMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                return GroupMessagesCollection(id: conversationId,
                                               name: name,
                                               groupId: groupId,
                                               latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        }
    }
    
    public func getAllMessagesForGroupConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        database.child("Group_Conversations/\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                print("Failed to load get all messages snapshot")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = dateFormatter.date(from: dateString) else {
                    print("A value is wrong")
                    return nil
                }
                
                // Handle message type
                var kind: MessageKind?
                if type == "photo" {
                    
                    // photo
                    guard let imageUrl = URL(string: content),
                          let placeholder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    
                    kind = .photo(media)
                    
                }
                else if type == "video" {
                    
                    // photo
                    guard let videoUrl = URL(string: content),
                          let placeholder = UIImage(named: "video_placeholder") else {
                        return nil
                    }
                    
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    
                    kind = .video(media)
                    
                }
                else if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponents[0]),
                          let latitude = Double(locationComponents[1]) else {
                        return nil
                    }
                    
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    
                    kind = .location(location)
                } else if type == "audio_call" {
                    kind = .audioCall(content)
                } else if type == "video_call" {
                    kind = .videoCall(content)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                
                let sender = Sender(photo: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            })
            
            completion(.success(messages))
        })
        
    }
    
    public func sendMessageGroup(to conversation: String, id: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        
        database.child("Group_Conversations/\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = dateFormatter.string(from: messageDate)
            
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
            case .audioCall(let callMessage):
                message = callMessage
                break
            case .videoCall(let callMessage):
                message = callMessage
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                // message
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "name": name,
                "is_read": false
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("Group_Conversations/\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("Users/\(currentEmail)/group_conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        // create conversation
                        var targetConversation: [String: Any]?
                        var position = 0
                        
                        for conversationDictionay in currentUserConversations {
                            if let currentId = conversationDictionay["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionay
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            // Set the lastest value
                            targetConversation["latest_message"] = updatedValue
                            
                            if position != 0 {
                                // Push the lastest message
                                for index in stride(from: 1, to: position + 1, by: 1).reversed() {
                                    currentUserConversations[index] = currentUserConversations[index - 1]
                                }
                                
                            }
                            
                            currentUserConversations[0] = targetConversation
                            
                            // Set the value back to the global variable
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "groupId": id,
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            
                            currentUserConversations.insert(newConversationData, at: 0)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "groupId": id,
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    
                    /// loop for every members and setValue
                    strongSelf.database.child("Groups/\(id)/members").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                        
                        if var members = snapshot.value as? [UserNode] {
                            for member in members {
                                
                                if member.email == currentEmail {continue}
                                
                                let safeOtherEmail = DatabaseManager.safeEmail(emailAddress: member.email)
                                
                                strongSelf.database.child("Users/\(safeOtherEmail)/group_conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        completion(false)
                                        return
                                    }
                                    
                                    completion(true)
                                })
                                
                            }
                        }
                        
                    })
                })
                
            }
            
            
            
        })
    }
    
    public func deleteGroupConversation(conversationId: String, completion: @escaping (Bool)->Void) {
        
    }
    
    public func groupConversationExists(with groupId: String, completion: @escaping (Result<String, Error>) -> Void ) {
        
        
        
    }
}
