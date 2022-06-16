//
//  ChannelToken.swift
//  Chit-Chat
//
//  Created by KhoiLe on 27/04/2022.
//

import Foundation

final class AgoraChannel {
    public static let shared = AgoraChannel()
    
    static var appID: String = "cf8f308e1fb3430e8dd8a4bbf0dcbf6e"
    static var channelId: String = "chitchat"
    
    static var token = "006cf8f308e1fb3430e8dd8a4bbf0dcbf6eIABkTYhWsyulePXNlBSOLLrz55Fa88+2MzhmAUi4rV2Bn5hPb+QAAAAAEADzS24feo2sYgEAAQB6jaxi"
    private let url = URL(string: "https://chit-chat-token-server.herokuapp.com/access_token?channel=chitchat&uid=1234")
}

public enum APIError: Error {
    case failedToReceive
}

extension AgoraChannel {
//    public func createChannel(completion: @escaping (Result<Bool, Error>) -> Void) {
//        guard url != nil else {
//            print("Error creating URL object")
//            completion(.failure(APIError.failedToReceive))
//            return
//        }
//
//        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: { data, response, _ in
//            do {
//                let tokenDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
//                //AgoraChannel.token = tokenDict["token"] as! String
//                completion(.success(true))
//            } catch {
//                print("Error in recieving data")
//                completion(.failure(APIError.failedToReceive))
//            }
//
//        })
//
//        dataTask.resume()
//    }
    
    func createChannel(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Start an async task
//        Task {
//            do {
//                let res: String? = try await ServiceManager.shared.getAgoraToken()
//
//                if let token = res {
//                    AgoraChannel.token = token
//                    completion(.success(true))
//                } else {
//                    throw(APIError.failedToReceive)
//                }
//
//            } catch {
//                print("Request failed with error: \(error)")
//                completion(.failure(APIError.failedToReceive))
//            }
//        }
        completion(.success(true))
    }
}
