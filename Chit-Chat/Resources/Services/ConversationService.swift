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
    
    func findTextInConversation(_ query: String) async throws -> [IMessInConversation]? {
        do {
            
            guard let url = ServiceManager.graphRequestClient(endPoint: "conversation") else {
                throw serviceError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = "query=\(query)"
            let payload = requestBody.data(using: .utf8)!
            
            let (responseData, _) = try await URLSession.shared.upload(for: request, from: payload)
            
            let data = try JSONDecoder().decode(IMessInConversationResponse.self, from: responseData)
            
            return data.result
            
        } catch {
            
            print("Failed to find text in conversation")
            throw serviceError.failedToUpload
            
        }
    }
}
