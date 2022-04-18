//
//  ServicesManager.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 10/04/2022.
//

import Foundation

public enum serviceError: Error {
    case invalidURL
    case failedToConnect
    case failedToGetData
    case failedToUpload
    case invalidResponseDataType
}

final public class ServiceManager {
    
    public static let shared = ServiceManager()
    
    let serviceURLString = "https://chit-chat-services.herokuapp.com"
    // let serviceURLString = "http://localhost:3000"
    
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
         
         let cons: [IMess]? = try await ServiceManager.shared.findTextInConversation("abc")
         
         if cons != nil {
             print(cons)
         }
         
     } catch {
         print("Request failed with error: \(error)")
     }
     
 }
 */
