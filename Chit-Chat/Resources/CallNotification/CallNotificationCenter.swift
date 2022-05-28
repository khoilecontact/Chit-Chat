//
//  CallNotificationCenter.swift
//  Chit-Chat
//
//  Created by KhoiLe on 12/05/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation

class CallNotificationCenter {
    public static let shared = CallNotificationCenter()
    
    //force to use this init
    private init() {}
    
    let database = Database.database(url: GeneralSettings.databaseUrl).reference()
    
    var calleEmail = ""
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public enum CallError: Error {
        case failedToConnectToServer
        case userIsInAnotherCall
    }
}

// CALLER
extension CallNotificationCenter {
    public func sendCallNotification(to callee: String, calleeName: String, conversationId: String, isAudio: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                  return
              }
        
        self.calleEmail = callee
        let calleeSafeEmail = DatabaseManager.safeEmail(emailAddress: callee)
        let ref = database.child("Calls/\(calleeSafeEmail)")
        
        var selfSender: Sender? {
            let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
            
            return  Sender(photo: "",
                           senderId: safeEmail,
                           displayName: "Me")
            
        }
        
        guard
            let selfSender = selfSender,
            let messageId = createMessageId() else {
            completion(.failure(CallError.failedToConnectToServer))
            return
        }
        
        let calleeMessage = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .custom("\(currentName) has called you"))
        
        DatabaseManager.shared.getAllMessagesForConversationSingleObserve(with: conversationId, completion: { result in
            switch result {
            // Existed conversation
            case .success(_):
                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: calleeName, name: calleeName, newMessage: calleeMessage, completion: { success in
                    if success {
                        completion(.success(true))
                    }
                    else {
                        completion(.failure(CallError.failedToConnectToServer))
                    }
                })
                break
            // New conversation
            case .failure(_):
                DatabaseManager.shared.createNewConversation(with: callee, name: calleeName, firstMessage: calleeMessage, completion: { success in
                    if success {
                        completion(.success(true))
                    } else {
                        completion(.failure(CallError.failedToConnectToServer))
                    }
                })
                break
            }
        })
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // Callee is in another call
            print(snapshot.value!)
            if !(snapshot.value is NSNull) {
                completion(.failure(CallError.userIsInAnotherCall))
            } else {
                let newCallData = [
                    "caller": currentName,
                    "caller_email": currentEmail,
                    "type": isAudio ? "Audio" : "Video"
                ]
                
                self?.database.child("Calls/\(calleeSafeEmail)").setValue(newCallData)
                completion(.success(true))
            }
        })
    }
    
    public func endCallCaller(to callee: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let calleeSafeEmail = DatabaseManager.safeEmail(emailAddress: callee)
        let ref = database.child("Calls/\(calleeSafeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if snapshot.value is NSNull {
                completion(.success(true))
            } else {
                self?.database.child("Calls/\(calleeSafeEmail)").removeValue()
                completion(.success(true))
            }
            
        })
    }
    
    public func listenCallEndedCaller(of callee: String, completion: @escaping (Bool) -> Void) {
        let calleeSafeEmail = DatabaseManager.safeEmail(emailAddress: callee)
        
        database.child("Calls/\(calleeSafeEmail)").observe(.value, with: { snapshot in
            if snapshot.value is NSNull {
                completion(true)
            }
            
            completion(false)
        })
    }
    
    private func createMessageId() -> String? {
        // date, otherEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(calleEmail)_\(safeCurrentEmail)_\(dateString)"
        
        return newIdentifier
    }
}

// CALLEE
extension CallNotificationCenter {
    public func listenForIncomingCall(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                  return
              }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        database.child("Calls/\(safeEmail)").observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                // Only one incoming call
                // Return the call notification
                if data.count == 3 {
                    // Display the incoming call screen
                    guard
                    let otherUserEmail = data["caller_email"] as? String,
                    let otherUserName = data["caller"] as? String,
                    let type = data["type"] else {
                        completion(.failure(CallError.failedToConnectToServer))
                        return
                    }
                    
                    completion(.success(["email": otherUserEmail,
                                         "name": otherUserName,
                                         "type": type]))
                    
                }
                
            }
            
            completion(.failure(CallError.failedToConnectToServer))
        })
        
    }
    
    public func listenCanceledCallCallee(completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                  return
              }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        database.child("Calls/\(safeEmail)").observe(.value, with: { snapshot in
            if snapshot.value is NSNull {
                completion(true)
            }
            
            completion(false)
        })
        
    }
    
    public func denyIncomingCall(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {return }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        database.child("Calls/\(safeCurrentEmail)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if snapshot.value is NSNull {
                completion(.success(true))
            } else {
                self?.database.child("Calls/\(safeCurrentEmail)").removeValue()
                completion(.success(true))
            }
        })
        
    }
    
    public func endCallCallee(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {return }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        database.child("Calls/\(safeCurrentEmail)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if snapshot.value is NSNull {
                completion(.success(true))
            } else {
                self?.database.child("Calls/\(safeCurrentEmail)").removeValue()
                completion(.success(true))
            }
        })
        
    }
    
    
}
