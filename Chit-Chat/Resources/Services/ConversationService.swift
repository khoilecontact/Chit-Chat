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
}
