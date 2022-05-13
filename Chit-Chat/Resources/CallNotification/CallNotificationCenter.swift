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
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// Push data for call
extension CallNotificationCenter {
    
}
