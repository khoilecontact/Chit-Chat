//
//  ConversationService.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 12/04/2022.
//

import Foundation

extension ServiceManager {
    // MARK: - Conversations
    
    func fetchConversationByConversationId() async throws -> [IMess]? {
        
        do {
            guard let url = ServiceManager.graphRequestClient(endPoint: "conversation") else {
                throw serviceError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let conversationData = try JSONDecoder().decode(IConversation.self, from: data)
            
            return conversationData.messages
        }
        catch {
            return nil
        }
    }
    
    func findTextInConversation(conversationID: String, query: String) async throws -> IMessInConversationResponse? {
        do {
            
            guard let url = ServiceManager.graphRequestClient(endPoint: "conversation") else {
                throw serviceError.invalidURL
            }
            
            let escapedConversationID = conversationID.replacingOccurrences(of: "+", with: "%2B")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = "conversationID=\(escapedConversationID)&query=\(query)"
            // JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
            let payload = requestBody.data(using: .utf8)!
            
            let (responseData, _) = try await URLSession.shared.upload(for: request, from: payload)
            
            let data = try JSONDecoder().decode(IMessInConversationResponse.self, from: responseData)
            
            return data
            
        } catch {
            
            print("Failed to find text in conversation")
            throw serviceError.failedToUpload
            
        }
    }
}
