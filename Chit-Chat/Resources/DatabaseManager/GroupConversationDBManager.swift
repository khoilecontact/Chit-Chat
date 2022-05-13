//
//  GroupConversationDBManager.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 14/05/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation

// MARK: Grouping and group

extension DatabaseManager {
    public func createNewGroupConversation(with id: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
    
    }
    
    private func finishCreatingGroupConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    public func getAllGroupConversation(for email: String, completion: @escaping (Result<[GroupMessagesCollection],Error>) -> Void) {
        
    }
    
    public func getAllMessagesForGroupConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
    }
    
    public func sendMessageGroup(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    public func deleteGroupConversation(conversationId: String, completion: @escaping (Bool)->Void) {
        
    }
    
    public func groupConversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void ) {
        
    }
}
