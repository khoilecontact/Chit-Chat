//
//  ConversationService.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 12/04/2022.
//

import Foundation
import ChatMessageKit
import Alamofire

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
    
    func findTextInGroupConversation(conversationID: String, query: String) async throws -> IMessInConversationResponse? {
        do {
            
            guard let url = ServiceManager.graphRequestClient(endPoint: "group-conversation") else {
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
            
            print("Failed to find text in group conversation")
            throw serviceError.failedToUpload
            
        }
    }
    
//    func translate(str: String, lang1: String, lang2: String, completion: @escaping (String) -> Void) {
//
//        let escapedStr = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//        let lastPart = lang1 + "&tl=" + lang2 + "&dt=t&dt=t&q=" + escapedStr!
//        let urlStr: String = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + lastPart
//        let url = URL(string: urlStr)
//
//        let task = URLSession.shared.downloadTask(with: url!) { localURL, urlResponse, error in
//            if let localURL = localURL {
//                if let string = try? String(contentsOf: localURL) {
//                    let index = string.firstIndex(of: "\"")
//                    let index2 = string.index(after: index!)
//                    let subst = string.substring(from: index2)
//                    let indexf = subst.firstIndex(of: "\"")
//                    let result = subst.substring(to: indexf!)
//
//                    completion(result)
//                }
//            }
//        }
//        task.resume()
//    }
    
    func translate(str: String, lang1: String, lang2: String, completion: @escaping (String) -> Void) {

        let escapedStr = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let lastPart = lang1 + "&tl=" + lang2 + "&dt=t&dt=t&q=" + escapedStr!
        let urlStr: String = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + lastPart
       
        AF.download(urlStr).response(completionHandler: { response in
            if let localURL = response.fileURL {
                if let string = try? String(contentsOf: localURL) {
                    let index = string.firstIndex(of: "\"")
                    let index2 = string.index(after: index!)
                    let subst = string.substring(from: index2)
                    let indexf = subst.firstIndex(of: "\"")
                    let result = subst.substring(to: indexf!)

                    completion(result)
                }
            }
        })
    }
    
    func translateAllTextMesages(messages: [Message], from: String, to: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        let myGroup = DispatchGroup()
        var messagesResult: [Message] = messages
        
        for messageIndex in 0 ..< messagesResult.count {
            switch messagesResult[messageIndex].kind {
            case .text(let content):
//                translate(str: content, lang1: from, lang2: to, completion: { translated in
//                    message.kind = .text(translated)
//                    print("Finish: \(translated)")
//                    myGroup.leave()
//                })
                myGroup.enter()
                
                DispatchQueue.global(qos: .background).async {
                    let escapedStr = content.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                    let lastPart = from + "&tl=" + to + "&dt=t&dt=t&q=" + escapedStr!
                    let urlStr: String = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + lastPart
                    
                    AF.download(urlStr).response(completionHandler: { [weak self] response in
                        if let localURL = response.fileURL {
                            if let string = try? String(contentsOf: localURL) {
                                let index = string.firstIndex(of: "\"")
                                let index2 = string.index(after: index!)
                                let subst = string.substring(from: index2)
                                let indexf = subst.firstIndex(of: "\"")
                                let result = subst.substring(to: indexf!)

                                self?.text = result
                                messagesResult[messageIndex].kind = .text(self?.text ?? "")
                                print("Finished request")
                                myGroup.leave()
                            }
                        }
                    })
                }
            default:
                continue
            }
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("all requests")
            print(self.text)
            //result[result.count - 1].kind = .text(self.text)
            completion(.success(messagesResult))
        })
        
        
    }
}
