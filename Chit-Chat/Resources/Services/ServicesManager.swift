//
//  ServicesManager.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 10/04/2022.
//

import Foundation

public enum serviceError: Error {
    case invalidURL
    case failToConnect
    case failToGetData
}

final public class ServiceManager {
    
    public static let shared = ServiceManager()
    
    let serviceURLString = "https://chit-chat-services.herokuapp.com"
    
    static func graphRequestClient(endPoint: String) -> URL? {
        
        return URL(string: "\(ServiceManager.shared.serviceURLString)/\(endPoint)")
    }
    
}

/**
 Usage:
 
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
 */
