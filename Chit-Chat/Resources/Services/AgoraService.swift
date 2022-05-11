//
//  AgoraService.swift
//  Chit-Chat
//
//  Created by KhoiLe on 11/05/2022.
//

import Foundation

extension ServiceManager  {
    func getAgoraToken() async throws -> String? {
        
        do {
            guard let url = ServiceManager.graphRequestClient(endPoint: "access_token") else {
                throw serviceError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let tokenData = try JSONDecoder().decode(IToken.self, from: data)
            
            return tokenData.token
        }
        catch {
            return nil
        }
    }
}
