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
    public func notifyNewMessage() {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                  return
              }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        database.child("Users/\(safeEmail)/conversations").observe(.childChanged, with: { [weak self] snapshot in
            // Check existed values
            guard let data = snapshot.value as? [String: Any],
                  let latestMessage = data["latest_message"] as? [String: Any],
                  let latestMessageContent  = latestMessage["message"] as? String,
//                  let otherUserSafeEmail = data["other_user_email"] as? String,
                  let senderName = data["name"] as? String,
                  let conversationId = data["id"] as? String
            else {
                return
            }
            
            self?.database.child("Conversations/\(conversationId)/messages").queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { conversationsSnapshot in
                guard let messageDic = conversationsSnapshot.value as? NSDictionary,
                      let latestMessage = messageDic.allValues[0] as? [String: Any]
                else {
                    return
                }
                
                guard let senderEmail = latestMessage["sender_email"] as? String else {
                    return
                }
                
                // Not notify user when in that chat
                if let tabBar = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController,
                   let nav = tabBar.selectedViewController as? UINavigationController,
                let messageChatVC = nav.visibleViewController as? MessageChatViewController {
                    if messageChatVC.conversationId == conversationId {
                        return
                    }
                }

                if senderEmail != safeEmail && senderEmail != currentEmail {
                    DispatchQueue.main.async {
                        self?.sendNotification(title: senderName, body: latestMessageContent, otherSafeEmail: senderEmail, conversationId: conversationId)
                        UIDevice.vibrate()
                    }
                }
                
            })
            

        })
    }
    
    private func sendNotification(title: String, body: String, otherSafeEmail: String, conversationId: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        //        notificationContent.subtitle = "Subtitle"
        notificationContent.body = body
        notificationContent.userInfo = [
            "conversationId": conversationId,
            "otherSafeEmail": otherSafeEmail,
            "name": title
        ]
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
