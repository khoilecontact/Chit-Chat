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
    
    let database = Database.database(url: GeneralSettings.databaseUrl).reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
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

public enum DatabaseError: Error {
    case failedToFetch
    case failedToFind
    case failedToSave
}

// MARK: -Sending messages / conversations

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

