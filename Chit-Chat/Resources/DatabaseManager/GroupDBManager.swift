//
//  GroupDBManager.swift
//  Chit-Chat
//
//  Created by KhoiLe on 21/04/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation

// MARK: Grouping and group

extension DatabaseManager {
    public func groupExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
    }
    
    public func insertGroup(with user: [User], completion: @escaping (Bool) -> Void) {
        
    }
    
    public func updateGroupInfo(with email: String, changesArray: [String: Any], completion: @escaping (Bool) -> Void) {
        
    }
    
    public func getAllGroupMembers(with id: String, completion: @escaping ((Bool) -> Void)) {
        
    }
    
}
