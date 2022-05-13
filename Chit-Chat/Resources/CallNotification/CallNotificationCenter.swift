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
        case failedToConnectToUser
        case userIsInAnotherCall
    }
}

// CALLER
extension CallNotificationCenter {
    public func sendCallNotification(to callee: String, calleeName: String, conversationId: String,completion: @escaping (Result<Bool, Error>) -> Void) {
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
            completion(.failure(CallError.failedToConnectToUser))
            return
        }
        
        let calleeMessage = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .custom("\(currentName) has called you"))
        
        DatabaseManager.shared.getAllMessagesForConversation(with: conversationId, completion: { result in
            switch result {
            // Existed conversation
            case .success(_):
                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: calleeName, name: calleeName, newMessage: calleeMessage, completion: { success in
                    if success {
                        completion(.success(true))
                    }
                    else {
                        completion(.failure(CallError.failedToConnectToUser))
                    }
                })
                break
            // New conversation
            case .failure(_):
                DatabaseManager.shared.createNewConversation(with: callee, name: calleeName, firstMessage: calleeMessage, completion: { success in
                    if success {
                        completion(.success(true))
                    } else {
                        completion(.failure(CallError.failedToConnectToUser))
                    }
                })
                break
            }
        })
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // Callee is in another call
            if snapshot.value != nil {
                completion(.failure(CallError.userIsInAnotherCall))
            } else {
                let newCallData = [
                    "caller": currentName,
                    "caller_email": currentEmail
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
            // Callee is in another call
            if snapshot.value != nil {
                completion(.success(true))
            } else {
                self?.database.child("Calls/\(calleeSafeEmail)").removeValue()
                completion(.success(true))
            }
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
    public func listenForIncomingCall() {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                  return
              }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        database.child("Calls/\(safeEmail)").observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                // Is in another call
                if data.count == 1 {
                    // Display the incoming call screen
                } else if data.count > 1 {
                    
                }
            }
        })
        
    }
}
