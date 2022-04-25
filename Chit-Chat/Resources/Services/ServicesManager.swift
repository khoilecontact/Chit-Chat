//
//  ServicesManager.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 10/04/2022.
//

import Foundation

public enum serviceError: Error {
    case invalidURL
    case invalidArguments
    case failedToConnect
    case failedToGetData
    case failedToUpload
    case invalidResponseDataType
}

final public class ServiceManager {
    
    public static let shared = ServiceManager()
    
//    let serviceURLString = "https://chit-chat-services.herokuapp.com"
    let serviceURLString = "http://localhost:3000"
    
    static func graphRequestClient(endPoint: String) -> URL? {
        
        return URL(string: "\(ServiceManager.shared.serviceURLString)/\(endPoint)")
    }
    
}

/**
 Usage:
 
 @Get
 func testServices() {
     // Start an async task
     Task {
         
         do {
             
             let cons: [IMess] = try await ServiceManager.shared.fetchConversationByConversationId()
             
         } catch {
             print("Request failed with error: \(error)")
         }
         
     }
 }
 
 
 @Post
 Task {
     
     do {
         
         let cons: [IMessInConversation]? = try await ServiceManager.shared.findTextInConversation(conversationID: "conversation_phatnguyen876-gmail,com_19521707-gm,uit,edu,vn_9:50:43 SA GMT+7, ngày 24 thg 3, 2022",query: "Mac+")
         
         if cons != nil {
             print(cons)
         }
         
     } catch {
         print("Request failed with error: \(error)")
     }
     
 }
 */
