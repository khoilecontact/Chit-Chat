//
//  MessageNotificationCenter.swift
//  Chit-Chat
//
//  Created by KhoiLe on 05/06/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import ChatMessageKit
import CoreLocation
import UserNotifications

class MessageNotificationCenter {
    public static let shared = MessageNotificationCenter()
    
    //force to use this init
    private init() {}
    
    let database = Database.database(url: GeneralSettings.databaseUrl).reference()
}

extension MessageNotificationCenter {
    public func listenForNewMessage() {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                  return
              }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        database.child("Users/\(safeEmail)/conversations").observe(.childChanged, with: { [weak self] snapshot in
            // Check existed values
            guard let data = snapshot.value as? [[String: Any]],
                  let latestMessage = data[0]["latest_message"] as? [String: Any],
                  let latestMessageContent  = latestMessage["message"] as? String,
                  let senderEmail = data[0]["other_user_email"] as? String,
                  let senderName = data[0]["name"] as? String
            else {
                return
            }
            
            if senderEmail != safeEmail && senderEmail != currentEmail {
                self?.sendNotification(title: senderName, body: latestMessageContent)
            }
        })
    }
    
    private func sendNotification(title: String, body: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        //        notificationContent.subtitle = "Subtitle"
        notificationContent.body = body
        notificationContent.badge = NSNumber(value: 1)
        
        if let url = Bundle.main.url(forResource: "dune",
                                     withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                              url: url,
                                                              options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "messageNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}
